DROP TABLE IF EXISTS 'users';
CREATE TABLE 'users' (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name VARCHAR(32),
  password VARCHAR(128)
);

DROP TABLE IF EXISTS 'roles';
CREATE TABLE 'roles' (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name VARCHAR(32),
  description VARCHAR(256)
);

DROP TABLE IF EXISTS 'users_roles';
CREATE TABLE 'users_roles' (
  user_id INTEGER,
  role_id INTEGER,
  PRIMARY KEY (user_id,role_id),
  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (role_id) REFERENCES roles(id)
);
