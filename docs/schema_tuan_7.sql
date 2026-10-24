-- ====================================================================
-- HỆ THỐNG HRM ENTERPRISE - CƠ SỞ DỮ LIỆU TUẦN 7 (POSTGRESQL)
-- MÔN: QUẢN LÝ DỰ ÁN PHẦN MỀM (QLDAPM) - NHÓM 12
-- PHỤ TRÁCH: PHẠM VĂN ĐOÀN (THÀNH VIÊN B)
-- ====================================================================

-- --------------------------------------------------------------------
-- PHÂN HỆ 1: ORGANIZATION SERVICE (DB: hrm_organization, Port: 4002)
-- --------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS "branches" (
    "id" VARCHAR(30) PRIMARY KEY,
    "name" VARCHAR(100) NOT NULL,
    "slug" VARCHAR(50) UNIQUE NOT NULL,
    "address" VARCHAR(255),
    "phone" VARCHAR(20),
    "manager" VARCHAR(100),
    "status" VARCHAR(30) DEFAULT 'hoạt động' NOT NULL,
    "staff" INTEGER DEFAULT 0 NOT NULL,
    "createdAt" TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL
);

CREATE TABLE IF NOT EXISTS "departments" (
    "id" VARCHAR(30) PRIMARY KEY,
    "name" VARCHAR(100) NOT NULL,
    "code" VARCHAR(50) UNIQUE NOT NULL,
    "manager" VARCHAR(100),
    "status" VARCHAR(30) DEFAULT 'hoạt động' NOT NULL,
    "staff" INTEGER DEFAULT 0 NOT NULL,
    "createdAt" TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL
);

CREATE TABLE IF NOT EXISTS "employees" (
    "id" VARCHAR(30) PRIMARY KEY,
    "name" VARCHAR(100) NOT NULL,
    "email" VARCHAR(100) UNIQUE NOT NULL,
    "phone" VARCHAR(20),
    "gender" VARCHAR(10),
    "birthDate" VARCHAR(20),
    "province" VARCHAR(100),
    "ward" VARCHAR(100),
    "street" VARCHAR(255),
    "cccd" VARCHAR(20),
    "branchSlug" VARCHAR(50),
    "department" VARCHAR(50),
    "role" VARCHAR(100),
    "systemRole" VARCHAR(20) DEFAULT 'staff' NOT NULL,
    "status" VARCHAR(30) DEFAULT 'đang làm' NOT NULL,
    "joinDate" VARCHAR(20),
    "createdAt" TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL
);

CREATE INDEX IF NOT EXISTS "idx_employees_branch" ON "employees" ("branchSlug");
CREATE INDEX IF NOT EXISTS "idx_employees_department" ON "employees" ("department");
CREATE INDEX IF NOT EXISTS "idx_employees_status" ON "employees" ("status");

-- --------------------------------------------------------------------
-- PHÂN HỆ 2: PAYROLL SERVICE (DB: hrm_payroll, Port: 4004)
-- --------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS "bank_accounts" (
    "id" VARCHAR(30) PRIMARY KEY,
    "accountNumber" VARCHAR(50) UNIQUE NOT NULL,
    "accountName" VARCHAR(100),
    "bankName" VARCHAR(100),
    "balance" DOUBLE PRECISION DEFAULT 0 NOT NULL,
    "status" VARCHAR(30) DEFAULT 'hoạt động' NOT NULL,
    "isPrimary" BOOLEAN DEFAULT FALSE NOT NULL,
    "createdAt" TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL
);

CREATE TABLE IF NOT EXISTS "payouts" (
    "id" VARCHAR(50) PRIMARY KEY,
    "bankReference" VARCHAR(100) UNIQUE NOT NULL,
    "debitAccount" VARCHAR(50) NOT NULL,
    "totalAmount" DOUBLE PRECISION NOT NULL,
    "content" VARCHAR(255),
    "beneficiaryCount" INTEGER DEFAULT 0 NOT NULL,
    "idempotencyKey" VARCHAR(100) UNIQUE NOT NULL,
    "status" VARCHAR(30) DEFAULT 'pending' NOT NULL,
    "createdAt" TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL
);

CREATE TABLE IF NOT EXISTS "payslips" (
    "id" VARCHAR(30) PRIMARY KEY,
    "employeeId" VARCHAR(30) NOT NULL,
    "month" VARCHAR(10) NOT NULL,
    "baseSalary" DOUBLE PRECISION DEFAULT 0 NOT NULL,
    "bonus" DOUBLE PRECISION DEFAULT 0 NOT NULL,
    "totalPenalty" DOUBLE PRECISION DEFAULT 0 NOT NULL,
    "netSalary" DOUBLE PRECISION DEFAULT 0 NOT NULL,
    "payoutId" VARCHAR(50),
    "status" VARCHAR(30) DEFAULT 'chưa chốt' NOT NULL,
    "issuedAt" TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT "uq_employee_month" UNIQUE ("employeeId", "month")
);

CREATE INDEX IF NOT EXISTS "idx_payslips_month" ON "payslips" ("month");
CREATE INDEX IF NOT EXISTS "idx_payslips_payout" ON "payslips" ("payoutId");

-- --------------------------------------------------------------------
-- PHÂN HỆ 3: WORK SERVICE (DB: hrm_work, Port: 4003)
-- --------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS "shifts" (
    "id" VARCHAR(30) PRIMARY KEY,
    "employeeId" VARCHAR(30) NOT NULL,
    "branchSlug" VARCHAR(50),
    "date" VARCHAR(20) NOT NULL,
    "template" VARCHAR(50),
    "scheduledStart" VARCHAR(10),
    "scheduledEnd" VARCHAR(10),
    "checkIn" VARCHAR(10),
    "checkOut" VARCHAR(10),
    "status" VARCHAR(30) DEFAULT 'đang làm' NOT NULL,
    "createdAt" TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL
);

CREATE TABLE IF NOT EXISTS "attendances" (
    "id" VARCHAR(30) PRIMARY KEY,
    "employeeId" VARCHAR(30) NOT NULL,
    "shiftId" VARCHAR(30),
    "date" VARCHAR(20) NOT NULL,
    "checkIn" VARCHAR(30),
    "checkOut" VARCHAR(30),
    "penaltyAmount" DOUBLE PRECISION DEFAULT 0 NOT NULL,
    "penaltyNote" VARCHAR(255),
    "status" VARCHAR(30) DEFAULT 'present' NOT NULL,
    "createdAt" TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL
);

CREATE TABLE IF NOT EXISTS "tasks" (
    "id" VARCHAR(30) PRIMARY KEY,
    "title" VARCHAR(150) NOT NULL,
    "description" TEXT,
    "assignedTo" VARCHAR(30),
    "branchSlug" VARCHAR(50),
    "dueDate" VARCHAR(30),
    "status" VARCHAR(30) DEFAULT 'pending' NOT NULL,
    "createdAt" TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL
);

CREATE INDEX IF NOT EXISTS "idx_shifts_employee_date" ON "shifts" ("employeeId", "date");
CREATE INDEX IF NOT EXISTS "idx_attendances_date" ON "attendances" ("date");
CREATE INDEX IF NOT EXISTS "idx_tasks_assigned" ON "tasks" ("assignedTo");
