"""
UI E2E tests for the Projects module of the Tracks application.

Each test maps 1:1 to a Functional Requirement (FR-001 ... FR-020).
Interactions go through the `projects_page` fixture (Page Object).
"""

from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC


# ---------- Listing & access ----------

def test_FR_001_project_visible_in_ui(projects_page, unique_project_name):
    projects_page.create(unique_project_name)
    projects_page.wait_for_flash("Created new project")

    projects_page.open()

    assert projects_page.list_contains(unique_project_name)


def test_FR_002_project_name_and_status_ui(projects_page, unique_project_name):
    projects_page.create(unique_project_name)
    projects_page.wait_for_flash("Created new project")

    projects_page.open()

    projects_text = projects_page.projects_text()
    assert unique_project_name in projects_text
    assert "(0 actions)" in projects_text


def test_FR_003_redirects_to_login_if_not_authenticated(driver, base_url):
    driver.delete_all_cookies()
    driver.get(f"{base_url}/projects")

    WebDriverWait(driver, 5).until(EC.presence_of_element_located((By.NAME, "user_login")))
    assert "Please log in" in driver.page_source


# ---------- Creation ----------

def test_FR_004_create_project_via_ui(projects_page, unique_project_name):
    projects_page.create(unique_project_name)
    projects_page.wait_for_project_in_list(unique_project_name)

    assert projects_page.list_contains(unique_project_name)


def test_FR_005_project_name_required_ui(projects_page):
    projects_page.fill_name("").submit_new()

    assert projects_page.driver.current_url.endswith("/projects")
    assert projects_page.name_value() == ""


def test_FR_006_project_success_message_ui(projects_page, unique_project_name):
    projects_page.create(unique_project_name)

    flash = projects_page.wait_for_flash(unique_project_name)
    assert unique_project_name in flash


def test_FR_007_created_project_visible_in_list(projects_page, unique_project_name):
    projects_page.create(unique_project_name)
    projects_page.wait_for_flash("Created new project")

    projects_page.open()

    assert projects_page.list_contains(unique_project_name)


def test_FR_008_prevent_duplicate_project_names_ui(projects_page, unique_project_name):
    projects_page.create(unique_project_name)
    projects_page.wait_for_project_in_list(unique_project_name)

    projects_page.create(unique_project_name)

    assert projects_page.driver.current_url.endswith("/projects")
    assert projects_page.name_value() == unique_project_name


def test_FR_009_project_name_max_length_ui(projects_page):
    projects_page.create("x" * 256)

    assert "Name project name must be less than 256 characters" in projects_page.error_text()


# FR-010: The application currently does NOT enforce the 65535-character description limit.
# This test is intentionally kept red to surface the gap between the requirement and the SUT.
def test_FR_010_project_description_max_length_ui(projects_page, unique_project_name):
    projects_page.fill_name(f"{unique_project_name}_valid")
    projects_page.fill_description("x" * 70000, via_js=True)
    projects_page.submit_new()

    error = projects_page.error_text().lower()
    assert "description" in error or "too long" in error


# ---------- Editing ----------

def test_FR_011_edit_project_name_and_description_ui(projects_page, unique_project_name):
    projects_page.create(unique_project_name, description="Initial description")
    projects_page.wait_for_project_in_list(unique_project_name)

    # Rename requires the full edit page (inline settings do not persist a rename).
    projects_page.open_edit(unique_project_name, inline=False)

    new_name = unique_project_name + "_edited"
    projects_page.fill_name(new_name).fill_description("Updated description").submit_edit_form()

    projects_page.open()
    assert projects_page.list_contains(new_name)


def test_FR_012_edit_project_has_name_field(projects_page, unique_project_name):
    projects_page.create(unique_project_name)
    projects_page.wait_for_project_in_list(unique_project_name)

    projects_page.open_edit(unique_project_name)

    assert projects_page.name_value() == unique_project_name


def test_FR_013_success_message_after_update_ui(projects_page, unique_project_name):
    projects_page.create(unique_project_name)
    projects_page.wait_for_project_in_list(unique_project_name)

    projects_page.open_edit(unique_project_name)
    projects_page.fill_description("updated").submit_edit()

    projects_page.wait_for_flash("Project saved")


def test_FR_014_project_changes_reflected_in_list_ui(projects_page, unique_project_name):
    projects_page.create(unique_project_name)
    projects_page.wait_for_project_in_list(unique_project_name)

    projects_page.open_edit(unique_project_name)
    projects_page.fill_description("Updated description").submit_edit()
    projects_page.wait_for_flash("Project saved")

    projects_page.open()
    assert projects_page.list_contains(unique_project_name)


def test_FR_015_prevent_duplicate_name_on_edit_ui(projects_page, unique_name):
    reserved_name = unique_name("fr_015_reserved")
    temp_name = unique_name("fr_015_temp")

    projects_page.create(reserved_name)
    projects_page.wait_for_project_in_list(reserved_name)

    projects_page.create(temp_name)
    projects_page.wait_for_project_in_list(temp_name)

    projects_page.open_edit(temp_name)
    projects_page.fill_name(reserved_name).submit_edit()

    assert "Name already exists" in projects_page.error_text()


# ---------- Deletion ----------

def test_FR_017_confirm_before_deleting_project(projects_page, unique_name):
    project_name = unique_name("fr_017_deletable")
    projects_page.create(project_name)
    projects_page.wait_for_project_in_list(project_name)

    projects_page.click_delete(project_name)

    alert = projects_page.wait_for_alert()
    assert "Are you sure" in alert.text
    assert project_name in alert.text
    alert.dismiss()

    projects_page.open()
    assert projects_page.list_contains(project_name), \
        "Project must remain when the confirmation dialog is dismissed"


def test_FR_018_deleted_project_disappears_from_list(projects_page, unique_name):
    project_name = unique_name("fr_018_to_be_deleted")
    projects_page.create(project_name)
    projects_page.wait_for_project_in_list(project_name)

    projects_page.click_delete(project_name)
    projects_page.wait_for_alert().accept()
    # Delete is AJAX-driven; wait for the server-side flash before re-reading the list.
    projects_page.wait_for_flash("Deleted project")

    projects_page.open()
    assert not projects_page.list_contains(project_name)


# FR-019 skipped intentionally: requires tasks-side verification of cascade delete,
# which is out of scope for the UI Projects suite.

def test_FR_020_success_message_after_deletion(projects_page, unique_name):
    project_name = unique_name("fr_020_success_message")
    projects_page.create(project_name)
    projects_page.wait_for_project_in_list(project_name)

    projects_page.click_delete(project_name)
    projects_page.wait_for_alert().accept()

    flash = projects_page.wait_for_flash("Deleted project")
    assert project_name in flash
