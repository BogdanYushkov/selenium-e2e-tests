"""Page Object for the /projects screen of the Tracks app."""

from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC

DEFAULT_TIMEOUT = 10


class ProjectsPage:
    URL_PATH = "/projects"

    # --- Locators ---
    NAME_INPUT = (By.ID, "project_name")
    DESCRIPTION_INPUT = (By.ID, "project_description")
    SUBMIT_NEW = (By.ID, "project_new_project_submit")
    SUBMIT_EDIT = (By.CSS_SELECTOR, "button[id^='submit_project_']")
    FLASH = (By.ID, "flash")
    ERROR_BOX = (By.ID, "errorExplanation")
    PROJECT_LIST = (By.ID, "list-active-projects")
    PROJECT_BLOCKS = (By.CSS_SELECTOR, "#list-active-projects .project")
    EDIT_LINK = (By.CSS_SELECTOR, "a[id^='link_edit_project_']")          # full edit page
    EDIT_SETTINGS = (By.CSS_SELECTOR, ".project_edit_settings")           # inline settings
    DELETE_BUTTON = (By.CLASS_NAME, "delete_project_button")

    def __init__(self, driver, base_url, timeout=DEFAULT_TIMEOUT):
        self.driver = driver
        self.base_url = base_url
        self.wait = WebDriverWait(driver, timeout)

    # --- Navigation ---
    def open(self):
        self.driver.get(f"{self.base_url}{self.URL_PATH}")
        self.wait.until(EC.presence_of_element_located(self.NAME_INPUT))
        return self

    # --- Form actions ---
    def fill_name(self, name):
        field = self.driver.find_element(*self.NAME_INPUT)
        field.clear()
        field.send_keys(name)
        return self

    def fill_description(self, description, via_js=False):
        if via_js:
            self.driver.execute_script(
                "document.getElementById('project_description').value = arguments[0];",
                description,
            )
        else:
            field = self.driver.find_element(*self.DESCRIPTION_INPUT)
            field.clear()
            field.send_keys(description)
        return self

    def submit_new(self):
        self.driver.find_element(*self.SUBMIT_NEW).click()
        return self

    def submit_edit(self):
        self.driver.find_element(*self.SUBMIT_EDIT).click()
        return self

    def submit_edit_form(self):
        """Submit by triggering the HTML form (used by the full-page edit flow)."""
        self.driver.find_element(*self.NAME_INPUT).submit()
        return self

    def create(self, name, description=None):
        """Fill the new-project form and submit."""
        self.fill_name(name)
        if description is not None:
            self.fill_description(description)
        self.submit_new()
        return self

    # --- Reads ---
    def name_value(self):
        return self.driver.find_element(*self.NAME_INPUT).get_attribute("value")

    def flash_text(self):
        self.wait.until(EC.visibility_of_element_located(self.FLASH))
        return self.driver.find_element(*self.FLASH).text.strip()

    def wait_for_flash(self, substring):
        self.wait.until(
            lambda d: substring in d.find_element(*self.FLASH).text
        )
        return self.driver.find_element(*self.FLASH).text.strip()

    def error_text(self):
        self.wait.until(EC.presence_of_element_located(self.ERROR_BOX))
        return self.driver.find_element(*self.ERROR_BOX).text

    def projects_text(self):
        self.wait.until(EC.presence_of_element_located(self.PROJECT_LIST))
        return self.driver.find_element(*self.PROJECT_LIST).text

    def wait_for_project_in_list(self, name):
        self.wait.until(
            lambda d: name in d.find_element(*self.PROJECT_LIST).text
        )
        return self

    def find_block(self, name):
        """Return the .project block whose text contains the given name (or None)."""
        self.wait.until(EC.presence_of_element_located(self.PROJECT_LIST))
        for block in self.driver.find_elements(*self.PROJECT_BLOCKS):
            if name in block.text:
                return block
        return None

    def list_contains(self, name):
        return name in self.projects_text()

    # --- Composite actions ---
    def open_edit(self, name, *, inline=True):
        """Open project edit; inline=True uses the settings panel, False opens the full-page form."""
        block = self.find_block(name)
        assert block is not None, f"Project '{name}' not found in list"
        locator = self.EDIT_SETTINGS if inline else self.EDIT_LINK
        block.find_element(*locator).click()
        # In both modes the page-level #project_name eventually carries the current project's name.
        self.wait.until(
            lambda d: d.find_element(*self.NAME_INPUT).get_attribute("value") == name
        )
        return self

    def click_delete(self, name):
        block = self.find_block(name)
        assert block is not None, f"Project '{name}' not found in list"
        block.find_element(*self.DELETE_BUTTON).click()
        return self

    def wait_for_alert(self):
        self.wait.until(EC.alert_is_present())
        return self.driver.switch_to.alert
