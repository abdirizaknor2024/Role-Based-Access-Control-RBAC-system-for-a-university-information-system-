
DROP DATABASE IF EXISTS university_rbac;
CREATE DATABASE university_rbac;
USE university_rbac;




CREATE TABLE users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);




CREATE TABLE roles (
    role_id INT AUTO_INCREMENT PRIMARY KEY,
    role_name VARCHAR(50) NOT NULL UNIQUE,
    description VARCHAR(255)
);




CREATE TABLE permissions (
    permission_id INT AUTO_INCREMENT PRIMARY KEY,
    permission_name VARCHAR(100) NOT NULL UNIQUE,
    description VARCHAR(255)
);



CREATE TABLE user_roles (
    user_id INT NOT NULL,
    role_id INT NOT NULL,

    PRIMARY KEY (user_id, role_id),

    FOREIGN KEY (user_id)
        REFERENCES users(user_id)
        ON DELETE CASCADE,

    FOREIGN KEY (role_id)
        REFERENCES roles(role_id)
        ON DELETE CASCADE
);




CREATE TABLE role_permissions (
    role_id INT NOT NULL,
    permission_id INT NOT NULL,

    PRIMARY KEY (role_id, permission_id),

    FOREIGN KEY (role_id)
        REFERENCES roles(role_id)
        ON DELETE CASCADE,

    FOREIGN KEY (permission_id)
        REFERENCES permissions(permission_id)
        ON DELETE CASCADE
);




INSERT INTO roles (role_name, description)
VALUES
('Admin', 'Full system administrator'),
('Teacher', 'University teacher'),
('Student', 'University student'),
('Registrar', 'Manages student registration'),
('Finance', 'Manages university financial records');




INSERT INTO permissions (permission_name, description)
VALUES
('VIEW_STUDENTS', 'View student information'),
('CREATE_STUDENT', 'Register new students'),
('UPDATE_STUDENT', 'Update student information'),
('DELETE_STUDENT', 'Delete student records'),

('VIEW_COURSES', 'View courses'),
('CREATE_COURSE', 'Create courses'),
('UPDATE_COURSE', 'Update courses'),

('VIEW_GRADES', 'View student grades'),
('ENTER_GRADES', 'Enter student grades'),
('UPDATE_GRADES', 'Update student grades'),

('VIEW_ATTENDANCE', 'View attendance'),
('MANAGE_ATTENDANCE', 'Manage student attendance'),

('VIEW_PAYMENTS', 'View payment information'),
('MANAGE_PAYMENTS', 'Manage student payments'),

('MANAGE_USERS', 'Manage system users'),
('MANAGE_ROLES', 'Manage roles and permissions');




INSERT INTO users
(username, password_hash, full_name, email)
VALUES
('admin01', 'HASH_ADMIN', 'System Administrator',
 'admin@university.edu'),

('teacher01', 'HASH_TEACHER', 'Ahmed Teacher',
 'teacher@university.edu'),

('student01', 'HASH_STUDENT', 'Ali Student',
 'student@university.edu'),

('registrar01', 'HASH_REGISTRAR', 'University Registrar',
 'registrar@university.edu'),

('finance01', 'HASH_FINANCE', 'Finance Officer',
 'finance@university.edu');




INSERT INTO user_roles (user_id, role_id)
VALUES
(1, 1),  -- Admin
(2, 2),  -- Teacher
(3, 3),  -- Student
(4, 4),  -- Registrar
(5, 5);  -- Finance




INSERT INTO role_permissions (role_id, permission_id)
SELECT 1, permission_id
FROM permissions;




INSERT INTO role_permissions (role_id, permission_id)
SELECT 2, permission_id
FROM permissions
WHERE permission_name IN (
    'VIEW_STUDENTS',
    'VIEW_COURSES',
    'VIEW_GRADES',
    'ENTER_GRADES',
    'UPDATE_GRADES',
    'VIEW_ATTENDANCE',
    'MANAGE_ATTENDANCE'
);



INSERT INTO role_permissions (role_id, permission_id)
SELECT 3, permission_id
FROM permissions
WHERE permission_name IN (
    'VIEW_COURSES',
    'VIEW_GRADES',
    'VIEW_ATTENDANCE'
);




INSERT INTO role_permissions (role_id, permission_id)
SELECT 4, permission_id
FROM permissions
WHERE permission_name IN (
    'VIEW_STUDENTS',
    'CREATE_STUDENT',
    'UPDATE_STUDENT',
    'VIEW_COURSES'
);



INSERT INTO role_permissions (role_id, permission_id)
SELECT 5, permission_id
FROM permissions
WHERE permission_name IN (
    'VIEW_STUDENTS',
    'VIEW_PAYMENTS',
    'MANAGE_PAYMENTS'
);



CREATE VIEW rbac_access AS
SELECT
    u.user_id,
    u.username,
    u.full_name,
    r.role_name,
    p.permission_name,
    CASE
        WHEN u.is_active = TRUE
             AND r.role_id IS NOT NULL
             AND p.permission_id IS NOT NULL
        THEN 'ALLOW'
        ELSE 'DENY'
    END AS decision
FROM users u
LEFT JOIN user_roles ur
    ON u.user_id = ur.user_id
LEFT JOIN roles r
    ON ur.role_id = r.role_id
LEFT JOIN role_permissions rp
    ON r.role_id = rp.role_id
LEFT JOIN permissions p
    ON rp.permission_id = p.permission_id;



SELECT
    user_id,
    username,
    full_name,
    role_name,
    permission_name,
    decision
FROM rbac_access
ORDER BY user_id, role_name, permission_name;




SELECT
    u.username,
    r.role_name,
    'ENTER_GRADES' AS requested_permission,
    CASE
        WHEN u.is_active = TRUE
             AND p.permission_name = 'ENTER_GRADES'
        THEN 'ALLOW'
        ELSE 'DENY'
    END AS decision
FROM users u
JOIN user_roles ur
    ON u.user_id = ur.user_id
JOIN roles r
    ON ur.role_id = r.role_id
LEFT JOIN role_permissions rp
    ON r.role_id = rp.role_id
LEFT JOIN permissions p
    ON rp.permission_id = p.permission_id
WHERE u.user_id = 2
AND (
    p.permission_name = 'ENTER_GRADES'
    OR p.permission_name IS NULL
);




SELECT
    u.v AS U,
    r.v AS R,
    p.v AS P,

    (u.v AND r.v) AS UR,

    (u.v AND r.v AND p.v) AS G,

    CASE
        WHEN u.v AND r.v AND p.v
        THEN 'ALLOW'
        ELSE 'DENY'
    END AS decision

FROM
    (SELECT 1 AS v UNION SELECT 0) u

CROSS JOIN
    (SELECT 1 AS v UNION SELECT 0) r

CROSS JOIN
    (SELECT 1 AS v UNION SELECT 0) p

ORDER BY
    u.v DESC,
    r.v DESC,
    p.v DESC;



