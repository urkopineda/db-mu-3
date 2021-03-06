-- 4.1-.
SELECT * FROM DEPT;
-- 4.2-.
SELECT EMP.ENAME, DEPT.DNAME FROM EMP, DEPT
WHERE EMP.DEPTNO = DEPT.DEPTNO;
	-- FORMAL
	SELECT EMP.ENAME, DEPT.DNAME
	FROM EMP JOIN DEPT ON EMP.DEPTNO = DEPT.DEPTNO
-- 4.3-.
INSERT INTO EMP VALUES(0000, 'URKO', 'THEMASTER', NULL, '2015-10-07', 10000, NULL, 40);
-- 4.4-.
SELECT DEPT.DNAME, COUNT(*)
FROM EMP, DEPT
WHERE EMP.DEPTNO = DEPT.DEPTNO
GROUP BY EMP.DEPTNO, DEPT.DNAME
	-- FORMAL
	SELECT DEPT.DNAME, COUNT(EMP.EMPNO)
	FROM EMP JOIN DEPT ON EMP.DEPTNO = DEPT.DEPTNO
	GROUP BY DEPT.DNAME
-- 4.5-.
SELECT ITEM.PRODID, SUM(ITEM.QTY) AS TOTAL FROM ITEM
GROUP BY ITEM.PRODID
ORDER BY TOTAL DESC;
-- 4.6-.
SELECT DEPT.DEPTNO, DEPT.DNAME, COUNT(*)
FROM DEPT JOIN EMP ON EMP.DEPTNO = DEPT.DEPTNO
GROUP BY DEPT.DEPTNO
HAVING COUNT(*) > 5;
