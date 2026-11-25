-- Up Migration
CREATE TABLE assignments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  course_id UUID NOT NULL REFERENCES courses(id),
  created_by UUID NOT NULL REFERENCES lecturers(user_id),
  title VARCHAR(200) NOT NULL,
  description TEXT NOT NULL DEFAULT '',
  deadline TIMESTAMPTZ NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX idx_assignments_course ON assignments(course_id);

CREATE TABLE assignment_submissions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  assignment_id UUID NOT NULL REFERENCES assignments(id),
  student_id UUID NOT NULL REFERENCES students(user_id),
  original_filename VARCHAR(255) NOT NULL,
  stored_filename VARCHAR(100) NOT NULL UNIQUE,
  mime_type VARCHAR(100) NOT NULL,
  size_bytes INTEGER NOT NULL CHECK (size_bytes > 0),
  sha256 CHAR(64) NOT NULL,
  is_latest BOOLEAN NOT NULL DEFAULT TRUE,
  submitted_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE UNIQUE INDEX uq_submission_latest
  ON assignment_submissions(assignment_id, student_id) WHERE is_latest;

-- Down Migration
DROP TABLE IF EXISTS assignment_submissions;
DROP TABLE IF EXISTS assignments;
