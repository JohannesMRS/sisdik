-- Jalankan hanya setelah akun demo dibuat melalui scripts/create-user.
-- Contoh akun: 2301001, 2301002, dan 19800101.

INSERT INTO courses (code, name, credits, semester)
VALUES
  ('IF101', 'Pemrograman Dasar', 3, 1),
  ('IF201', 'Algoritma dan Struktur Data', 3, 3),
  ('IF301', 'Pengembangan Aplikasi Mobile', 3, 5)
ON CONFLICT (code) DO UPDATE SET
  name = EXCLUDED.name,
  credits = EXCLUDED.credits,
  semester = EXCLUDED.semester;

INSERT INTO lecturer_courses (lecturer_id, course_id)
SELECT l.user_id, c.id
FROM lecturers l
JOIN users u ON u.id = l.user_id
CROSS JOIN courses c
WHERE u.identifier = '19800101'
ON CONFLICT DO NOTHING;

INSERT INTO course_schedules (course_id, day_of_week, start_time, end_time, room)
SELECT c.id, s.day_of_week, s.start_time::time, s.end_time::time, s.room
FROM courses c
CROSS JOIN LATERAL (
  VALUES
    ('IF101', 1, '08.00', '09.40', 'A101'),
    ('IF101', 3, '10.00', '11.40', 'A102'),
    ('IF201', 2, '08.00', '09.40', 'B201'),
    ('IF301', 4, '13.00', '14.40', 'C301')
) AS s(code, day_of_week, start_time, end_time, room)
WHERE c.code = s.code
ON CONFLICT DO NOTHING;

INSERT INTO student_courses (student_id, course_id, academic_term)
SELECT st.user_id, c.id, '2026/2027 Ganjil'
FROM students st
JOIN users u ON u.id = st.user_id
CROSS JOIN courses c
WHERE u.identifier IN ('2301001', '2301002')
  AND c.code IN ('IF101', 'IF201', 'IF301')
ON CONFLICT DO NOTHING;

INSERT INTO assignments (course_id, created_by, title, description, deadline)
SELECT c.id, l.user_id, a.title, a.description, a.deadline::timestamptz
FROM courses c
JOIN lecturer_courses lc ON lc.course_id = c.id
JOIN lecturers l ON l.user_id = lc.lecturer_id
CROSS JOIN LATERAL (
  VALUES
    ('IF201', 'Tugas 1: Struktur Data', 'Implementasikan struktur data dasar.', '2026-12-05 16:59:00+07'),
    ('IF301', 'Tugas 1: Layout Mobile', 'Buat tampilan aplikasi sesuai rancangan UI.', '2026-12-08 16:59:00+07')
) AS a(code, title, description, deadline)
WHERE c.code = a.code;
