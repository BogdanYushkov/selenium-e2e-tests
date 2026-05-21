create table tracks.ar_internal_metadata
(
    `key`      varchar(255) not null
        primary key,
    value      varchar(255) null,
    created_at datetime(6)  not null,
    updated_at datetime(6)  not null
);

create table tracks.attachments
(
    id                bigint auto_increment
        primary key,
    todo_id           int          null,
    file_file_name    varchar(255) null,
    file_content_type varchar(255) null,
    file_file_size    int          null,
    file_updated_at   datetime     null,
    created_at        datetime     null,
    updated_at        datetime     null
);

create index index_attachments_on_todo_id
    on tracks.attachments (todo_id);

create table tracks.contexts
(
    id         bigint auto_increment
        primary key,
    name       varchar(255)                 not null,
    position   int         default 0        null,
    user_id    int         default 1        null,
    created_at datetime                     null,
    updated_at datetime                     null,
    state      varchar(20) default 'active' not null
);

create index index_contexts_on_user_id
    on tracks.contexts (user_id);

create index index_contexts_on_user_id_and_name
    on tracks.contexts (user_id, name);

create table tracks.dependencies
(
    id                bigint auto_increment
        primary key,
    successor_id      int          not null,
    predecessor_id    int          not null,
    relationship_type varchar(255) null
);

create index index_dependencies_on_predecessor_id
    on tracks.dependencies (predecessor_id);

create index index_dependencies_on_successor_id
    on tracks.dependencies (successor_id);

create table tracks.individual
(
    Id       int  not null
        primary key,
    name     char null,
    address  char null,
    city     char null,
    order_id int  null,
    constraint table_name_order_id_uindex
        unique (order_id)
);

create table tracks.notes
(
    id         bigint auto_increment
        primary key,
    user_id    int      not null,
    project_id int      not null,
    body       text     null,
    created_at datetime null,
    updated_at datetime null
);

create index index_notes_on_project_id
    on tracks.notes (project_id);

create index index_notes_on_user_id
    on tracks.notes (user_id);

create table tracks.open_id_authentication_associations
(
    id         bigint auto_increment
        primary key,
    issued     int          null,
    lifetime   int          null,
    handle     varchar(255) null,
    assoc_type varchar(255) null,
    server_url blob         null,
    secret     blob         null
);

create table tracks.open_id_authentication_nonces
(
    id         bigint auto_increment
        primary key,
    timestamp  int          not null,
    server_url varchar(255) null,
    salt       varchar(255) not null
);

create table tracks.`order`
(
    id        int       not null
        primary key,
    item_name char(255) null,
    date      char      null,
    price     int       not null
);

create table tracks.preferences
(
    id                                 bigint auto_increment
        primary key,
    user_id                            int                                 not null,
    date_format                        varchar(40)  default '%d/%m/%Y'     not null,
    week_starts                        int          default 0              not null,
    show_number_completed              int          default 5              not null,
    staleness_starts                   int          default 7              not null,
    show_completed_projects_in_sidebar tinyint(1)   default 1              not null,
    show_hidden_contexts_in_sidebar    tinyint(1)   default 1              not null,
    due_style                          int          default 0              not null,
    refresh                            int          default 0              not null,
    verbose_action_descriptors         tinyint(1)   default 0              not null,
    show_hidden_projects_in_sidebar    tinyint(1)   default 1              not null,
    time_zone                          varchar(255) default 'London'       not null,
    show_project_on_todo_done          tinyint(1)   default 0              not null,
    title_date_format                  varchar(255) default '%A, %d %B %Y' not null,
    mobile_todos_per_page              int          default 6              not null,
    sms_email                          varchar(255)                        null,
    sms_context_id                     int                                 null,
    locale                             varchar(255)                        null,
    review_period                      int          default 14             not null,
    theme                              varchar(255)                        null
);

create index index_preferences_on_user_id
    on tracks.preferences (user_id);

create table tracks.projects
(
    id                 bigint auto_increment
        primary key,
    name               varchar(255)  not null,
    position           int default 0 null,
    user_id            int default 1 null,
    description        mediumtext    null,
    state              varchar(20)   not null,
    created_at         datetime      null,
    updated_at         datetime      null,
    default_context_id int           null,
    completed_at       datetime      null,
    default_tags       varchar(255)  null,
    last_reviewed      datetime      null
);

create index index_projects_on_state
    on tracks.projects (state);

create index index_projects_on_user_id
    on tracks.projects (user_id);

create index index_projects_on_user_id_and_name
    on tracks.projects (user_id, name);

create index index_projects_on_user_id_and_state
    on tracks.projects (user_id, state);

create table tracks.recurring_todos
(
    id                    bigint auto_increment
        primary key,
    user_id               int        default 1 null,
    context_id            int                  not null,
    project_id            int                  null,
    description           varchar(255)         not null,
    notes                 mediumtext           null,
    state                 varchar(20)          not null,
    start_from            datetime             null,
    ends_on               varchar(255)         null,
    end_date              datetime             null,
    number_of_occurrences int                  null,
    occurrences_count     int        default 0 null,
    target                varchar(255)         null,
    show_from_delta       int                  null,
    recurring_period      varchar(255)         null,
    recurrence_selector   int                  null,
    every_other1          int                  null,
    every_other2          int                  null,
    every_other3          int                  null,
    every_day             varchar(255)         null,
    only_work_days        tinyint(1) default 0 null,
    every_count           int                  null,
    weekday               int                  null,
    completed_at          datetime             null,
    created_at            datetime             null,
    updated_at            datetime             null,
    show_always           tinyint(1)           null
);

create index index_recurring_todos_on_state
    on tracks.recurring_todos (state);

create index index_recurring_todos_on_user_id
    on tracks.recurring_todos (user_id);

create table tracks.schema_migrations
(
    version varchar(255) not null
        primary key
);

create table tracks.sessions
(
    id         bigint auto_increment
        primary key,
    session_id varchar(255) null,
    data       text         null,
    updated_at datetime     null
);

create index sessions_session_id_index
    on tracks.sessions (session_id);

create table tracks.taggings
(
    id            bigint auto_increment
        primary key,
    taggable_id   int          null,
    tag_id        int          null,
    taggable_type varchar(255) null
);

create index index_taggings_on_tag_id
    on tracks.taggings (tag_id);

create index index_taggings_on_tag_id_and_taggable_id_and_taggable_type
    on tracks.taggings (tag_id, taggable_id, taggable_type);

create index index_taggings_on_taggable_id_and_taggable_type
    on tracks.taggings (taggable_id, taggable_type);

create table tracks.tags
(
    id         bigint auto_increment
        primary key,
    name       varchar(255) null,
    created_at datetime     null,
    updated_at datetime     null,
    user_id    int          null
);

create index index_tags_on_name
    on tracks.tags (name);

create table tracks.todos
(
    id                bigint auto_increment
        primary key,
    context_id        int           not null,
    project_id        int           null,
    description       text          not null,
    notes             mediumtext    null,
    created_at        datetime      null,
    due               datetime      null,
    completed_at      datetime      null,
    user_id           int default 1 null,
    show_from         datetime      null,
    state             varchar(20)   not null,
    recurring_todo_id int           null,
    updated_at        datetime      null,
    rendered_notes    mediumtext    null
);

create index index_todos_on_context_id
    on tracks.todos (context_id);

create index index_todos_on_project_id
    on tracks.todos (project_id);

create index index_todos_on_state
    on tracks.todos (state);

create index index_todos_on_user_id_and_context_id
    on tracks.todos (user_id, context_id);

create index index_todos_on_user_id_and_project_id
    on tracks.todos (user_id, project_id);

create index index_todos_on_user_id_and_state
    on tracks.todos (user_id, state);

create table tracks.tolk_locales
(
    id         bigint auto_increment
        primary key,
    name       varchar(255) null,
    created_at datetime     null,
    updated_at datetime     null,
    constraint index_tolk_locales_on_name
        unique (name)
);

create table tracks.tolk_phrases
(
    id         bigint auto_increment
        primary key,
    `key`      text     null,
    created_at datetime null,
    updated_at datetime null
);

create table tracks.tolk_translations
(
    id              bigint auto_increment
        primary key,
    phrase_id       int                  null,
    locale_id       int                  null,
    text            text                 null,
    previous_text   text                 null,
    primary_updated tinyint(1) default 0 null,
    created_at      datetime             null,
    updated_at      datetime             null,
    constraint index_tolk_translations_on_phrase_id_and_locale_id
        unique (phrase_id, locale_id)
);

create table tracks.users
(
    id                        bigint auto_increment
        primary key,
    login                     varchar(80)                     not null,
    crypted_password          varchar(60)                     null,
    token                     varchar(255)                    null,
    is_admin                  tinyint(1)   default 0          not null,
    first_name                varchar(255)                    null,
    last_name                 varchar(255)                    null,
    auth_type                 varchar(255) default 'database' not null,
    open_id_url               varchar(255)                    null,
    remember_token            varchar(255)                    null,
    remember_token_expires_at datetime                        null,
    email                     varchar(255)                    null,
    created_at                datetime                        null,
    updated_at                datetime                        null,
    last_login_at             datetime                        null
);

create index index_users_on_login
    on tracks.users (login);

-- ИСПОЛЬЗУЕМ INSERT ... ON DUPLICATE KEY UPDATE для идемпотентности
INSERT INTO tracks.users (id, login, crypted_password, token, is_admin, first_name, last_name, auth_type, open_id_url, remember_token, remember_token_expires_at, email, created_at, updated_at, last_login_at) VALUES (1, 'admin', '$2a$12$CvrgzDC.3Cw2auf6awvnueMz8oy8r11WiSx6v2Enpzx7LPBFgXD8m', '60c2f3c47542a7be1ddfe4509a0edb6ef623a051', 1, null, null, 'database', null, null, null, 'admin@gmail.com', '2023-01-25 13:05:28', '2023-01-25 13:05:28', null)
ON DUPLICATE KEY UPDATE
    login=VALUES(login),
    crypted_password=VALUES(crypted_password),
    token=VALUES(token),
    is_admin=VALUES(is_admin),
    first_name=VALUES(first_name),
    last_name=VALUES(last_name),
    auth_type=VALUES(auth_type),
    open_id_url=VALUES(open_id_url),
    remember_token=VALUES(remember_token),
    remember_token_expires_at=VALUES(remember_token_expires_at),
    email=VALUES(email),
    created_at=VALUES(created_at),
    updated_at=VALUES(updated_at),
    last_login_at=VALUES(last_login_at);

INSERT INTO tracks.preferences (id, user_id, date_format, week_starts, show_number_completed, staleness_starts, show_completed_projects_in_sidebar, show_hidden_contexts_in_sidebar, due_style, refresh, verbose_action_descriptors, show_hidden_projects_in_sidebar, time_zone, show_project_on_todo_done, title_date_format, mobile_todos_per_page, sms_email, sms_context_id, locale, review_period, theme) VALUES (1, 1, '%d/%m/%Y', 0, 5, 7, 1, 1, 0, 0, 0, 1, 'London', 0, '%A, %d %B %Y', 6, null, null, 'en', 14, null)
ON DUPLICATE KEY UPDATE
    user_id=VALUES(user_id),
    date_format=VALUES(date_format),
    week_starts=VALUES(week_starts),
    show_number_completed=VALUES(show_number_completed),
    staleness_starts=VALUES(staleness_starts),
    show_completed_projects_in_sidebar=VALUES(show_completed_projects_in_sidebar),
    show_hidden_contexts_in_sidebar=VALUES(show_hidden_contexts_in_sidebar),
    due_style=VALUES(due_style),
    refresh=VALUES(refresh),
    verbose_action_descriptors=VALUES(verbose_action_descriptors),
    show_hidden_projects_in_sidebar=VALUES(show_hidden_projects_in_sidebar),
    time_zone=VALUES(time_zone),
    show_project_on_todo_done=VALUES(show_project_on_todo_done),
    title_date_format=VALUES(title_date_format),
    mobile_todos_per_page=VALUES(mobile_todos_per_page),
    sms_email=VALUES(sms_email),
    sms_context_id=VALUES(sms_context_id),
    locale=VALUES(locale),
    review_period=VALUES(review_period),
    theme=VALUES(theme);
