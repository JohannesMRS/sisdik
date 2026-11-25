-- Up Migration
CREATE TABLE courses (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  code VARCHAR(20) NOT NULL UNIQUE,
  name VARCHAR(150) NOT NULL,
  credits SMALLINT NOT NULL CHECK (credits BETWEEN 1 AND 6),
  semester SMALLINT NOT NULL CHECK (semester BETWEEN 1 AND 8)
);

CREATE TABLE course_schedules (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  course_id UUID NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
  day_of_week SMALLINT NOT NULL CHECK (day_of_week BETWEEN 1 AND 7),
  start_time TIME NOT NULL,
  end_time TIME NOT NULL,
  room VARCHAR(50),
  CHECK (end_time > start_time)
);

CREATE TABLE student_courses (
  student_id UUID NOT NULL REFERENCES students(user_id) ON DELETE CASCADE,
  course_id UUID NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
  academic_term VARCHAR(20) NOT NULL,
  PRIMARY KEY (student_id, course_id)
);

CREATE TABLE lecturer_courses (
  lecturer_id UUID NOT NULL REFERENCES lecturers(user_id) ON DELETE CASCADE,
  course_id UUID NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
  PRIMARY KEY (lecturer_id, course_id)
);

-- Down Migration
DROP TABLE IF EXISTS lecturer_courses;
DROP TABLE IF EXISTS student_courses;
DROP TABLE IF EXISTS course_schedules;
DROP TABLE IF EXISTS courses;
