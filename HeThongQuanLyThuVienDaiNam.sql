/*
============================================================
BAN SQL DA SUA - HE THONG QUAN LY THU VIEN DAI NAM
Database: HeThongQuanLyThuVien
Nen tang: Microsoft SQL Server

QUAN TRONG:
1. Mo file nay trong SSMS bang File > Open > File.
2. Bam Ctrl+A de chon TOAN BO noi dung file.
3. Bam F5 de chay TOAN BO file, khong chi chay cac dong SELECT o cuoi.
4. Script tu tao database neu chua co, sau do tao bang, du lieu mau,
   thu tuc, view, index va cac truy van kiem tra.
5. Script khong DROP/XOA database cu va khong tu dong chay giao dich demo.

Neu chi chay rieng Phan 7 hoac Phan 8, SQL Server se bao
'Invalid object name' neu cac bang chua duoc tao.
============================================================
*/

USE master;
GO

IF DB_ID(N'HeThongQuanLyThuVien') IS NULL
BEGIN
    CREATE DATABASE HeThongQuanLyThuVien;
END;
GO

USE HeThongQuanLyThuVien;
GO

PRINT N'Dang khoi tao CSDL HeThongQuanLyThuVien...';
GO

-- Dam bao cac lenh tao bang va truy van duoc chay dung CSDL.
IF DB_NAME() <> N'HeThongQuanLyThuVien'
BEGIN
    THROW 51000, N'Ban dang chon sai co so du lieu. Hay chay lai toan bo file.', 1;
END;
GO

/*============================================================
  PHAN 1. TAO CAC BANG DANH MUC VA NGHIEP VU CO BAN
============================================================*/

IF OBJECT_ID(N'dbo.NhaXuatBan', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.NhaXuatBan (
        MaNXB VARCHAR(10) NOT NULL PRIMARY KEY,
        TenNXB NVARCHAR(150) NOT NULL UNIQUE,
        DiaChi NVARCHAR(200) NULL,
        SoDienThoai VARCHAR(15) NULL,
        Email VARCHAR(120) NULL
    );
END;
GO

IF OBJECT_ID(N'dbo.TheLoai', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.TheLoai (
        MaTheLoai VARCHAR(10) NOT NULL PRIMARY KEY,
        TenTheLoai NVARCHAR(100) NOT NULL UNIQUE,
        MoTa NVARCHAR(300) NULL
    );
END;
GO

IF OBJECT_ID(N'dbo.TacGia', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.TacGia (
        MaTacGia VARCHAR(10) NOT NULL PRIMARY KEY,
        TenTacGia NVARCHAR(120) NOT NULL,
        NamSinh SMALLINT NULL CHECK (NamSinh BETWEEN 1000 AND 2100),
        QuocTich NVARCHAR(60) NULL
    );
END;
GO

IF OBJECT_ID(N'dbo.DocGia', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.DocGia (
        MaDocGia VARCHAR(10) NOT NULL PRIMARY KEY,
        HoTen NVARCHAR(120) NOT NULL,
        NgaySinh DATE NULL,
        GioiTinh NVARCHAR(10) NULL
            CHECK (GioiTinh IN (N'Nam', N'Nữ', N'Khác')),
        DiaChi NVARCHAR(200) NULL,
        SoDienThoai VARCHAR(15) NULL,
        Email VARCHAR(120) NULL UNIQUE,
        LoaiDocGia NVARCHAR(20) NOT NULL
            CHECK (LoaiDocGia IN (N'Sinh viên', N'Giảng viên', N'Nhân viên')),
        NgayDangKy DATE NOT NULL DEFAULT (CONVERT(date, GETDATE())),
        NgayHetHanThe DATE NOT NULL,
        CONSTRAINT CK_DocGia_HanThe
            CHECK (NgayHetHanThe >= NgayDangKy)
    );
END;
GO

IF OBJECT_ID(N'dbo.NhanVien', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.NhanVien (
        MaNhanVien VARCHAR(10) NOT NULL PRIMARY KEY,
        HoTen NVARCHAR(120) NOT NULL,
        SoDienThoai VARCHAR(15) NULL,
        Email VARCHAR(120) NULL UNIQUE,
        ChucVu NVARCHAR(60) NOT NULL,
        TrangThai NVARCHAR(20) NOT NULL DEFAULT N'Đang làm'
            CHECK (TrangThai IN (N'Đang làm', N'Tạm nghỉ', N'Nghỉ việc'))
    );
END;
GO

IF OBJECT_ID(N'dbo.Sach', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Sach (
        MaSach VARCHAR(10) NOT NULL PRIMARY KEY,
        TenSach NVARCHAR(200) NOT NULL,
        MaNXB VARCHAR(10) NOT NULL,
        MaTheLoai VARCHAR(10) NOT NULL,
        NamXuatBan SMALLINT NULL CHECK (NamXuatBan BETWEEN 1450 AND 2100),
        LanXuatBan INT NOT NULL DEFAULT 1 CHECK (LanXuatBan >= 1),
        SoTrang INT NOT NULL CHECK (SoTrang > 0),
        GiaSach DECIMAL(12,2) NOT NULL DEFAULT 0 CHECK (GiaSach >= 0),
        NgonNgu NVARCHAR(40) NOT NULL DEFAULT N'Tiếng Việt',
        ViTriKe NVARCHAR(30) NOT NULL,
        SoLuongTong INT NOT NULL CHECK (SoLuongTong >= 0),
        SoLuongCon INT NOT NULL
            CHECK (SoLuongCon >= 0 AND SoLuongCon <= SoLuongTong),
        TrangThai NVARCHAR(20) NOT NULL DEFAULT N'Đang lưu hành'
            CHECK (TrangThai IN (N'Đang lưu hành', N'Tạm ngừng', N'Thanh lý')),
        CONSTRAINT FK_Sach_NXB FOREIGN KEY (MaNXB)
            REFERENCES dbo.NhaXuatBan(MaNXB),
        CONSTRAINT FK_Sach_TheLoai FOREIGN KEY (MaTheLoai)
            REFERENCES dbo.TheLoai(MaTheLoai)
    );
END;
GO

IF OBJECT_ID(N'dbo.Sach_TacGia', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Sach_TacGia (
        MaSach VARCHAR(10) NOT NULL,
        MaTacGia VARCHAR(10) NOT NULL,
        VaiTro NVARCHAR(40) NULL DEFAULT N'Tác giả',
        CONSTRAINT PK_Sach_TacGia PRIMARY KEY (MaSach, MaTacGia),
        CONSTRAINT FK_STG_Sach FOREIGN KEY (MaSach)
            REFERENCES dbo.Sach(MaSach),
        CONSTRAINT FK_STG_TacGia FOREIGN KEY (MaTacGia)
            REFERENCES dbo.TacGia(MaTacGia)
    );
END;
GO

IF OBJECT_ID(N'dbo.PhieuMuon', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.PhieuMuon (
        MaPhieu VARCHAR(10) NOT NULL PRIMARY KEY,
        MaDocGia VARCHAR(10) NOT NULL,
        MaNhanVien VARCHAR(10) NOT NULL,
        NgayMuon DATE NOT NULL DEFAULT (CONVERT(date, GETDATE())),
        HanTra DATE NOT NULL,
        TrangThaiPhieu NVARCHAR(20) NOT NULL DEFAULT N'Đang mượn'
            CHECK (TrangThaiPhieu IN (N'Đang mượn', N'Đã trả', N'Quá hạn', N'Đã hủy')),
        GhiChu NVARCHAR(300) NULL,
        CONSTRAINT CK_PhieuMuon_HanTra CHECK (HanTra >= NgayMuon),
        CONSTRAINT FK_PM_DocGia FOREIGN KEY (MaDocGia)
            REFERENCES dbo.DocGia(MaDocGia),
        CONSTRAINT FK_PM_NhanVien FOREIGN KEY (MaNhanVien)
            REFERENCES dbo.NhanVien(MaNhanVien)
    );
END;
GO

IF OBJECT_ID(N'dbo.ChiTietPhieuMuon', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.ChiTietPhieuMuon (
        MaPhieu VARCHAR(10) NOT NULL,
        MaSach VARCHAR(10) NOT NULL,
        SoLuongMuon INT NOT NULL CHECK (SoLuongMuon > 0),
        NgayTra DATE NULL,
        TinhTrangTra NVARCHAR(30) NULL
            CHECK (TinhTrangTra IN (N'Tốt', N'Trầy xước', N'Hư hỏng', N'Mất')),
        GhiChu NVARCHAR(300) NULL,
        CONSTRAINT PK_ChiTietPhieuMuon PRIMARY KEY (MaPhieu, MaSach),
        CONSTRAINT CK_CTPM_NgayTra
            CHECK (NgayTra IS NULL OR NgayTra >= '20000101'),
        CONSTRAINT FK_CTPM_Phieu FOREIGN KEY (MaPhieu)
            REFERENCES dbo.PhieuMuon(MaPhieu),
        CONSTRAINT FK_CTPM_Sach FOREIGN KEY (MaSach)
            REFERENCES dbo.Sach(MaSach)
    );
END;
GO

/*============================================================
  PHAN 2. CAC BANG MO RONG QUAN LY TUNG BAN SAO VA TRA SACH
============================================================*/

IF OBJECT_ID(N'dbo.BanSao', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.BanSao (
        MaBanSao VARCHAR(12) NOT NULL PRIMARY KEY,
        MaSach VARCHAR(10) NOT NULL,
        TinhTrang NVARCHAR(20) NOT NULL DEFAULT N'Tốt'
            CHECK (TinhTrang IN (N'Tốt', N'Hư hỏng', N'Mất')),
        TrangThai NVARCHAR(20) NOT NULL DEFAULT N'Sẵn sàng'
            CHECK (TrangThai IN (N'Sẵn sàng', N'Đang mượn', N'Hư hỏng', N'Mất')),
        NgayNhap DATE NOT NULL,
        GhiChu NVARCHAR(200) NULL,
        CONSTRAINT FK_BanSao_Sach FOREIGN KEY (MaSach)
            REFERENCES dbo.Sach(MaSach)
    );
END;
GO

IF OBJECT_ID(N'dbo.MuonBanSao', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.MuonBanSao (
        MaPhieu VARCHAR(10) NOT NULL,
        MaBanSao VARCHAR(12) NOT NULL,
        NgayTraDuKien DATE NOT NULL,
        NgayTraThucTe DATE NULL,
        CONSTRAINT PK_MuonBanSao PRIMARY KEY (MaPhieu, MaBanSao),
        CONSTRAINT FK_MBS_Phieu FOREIGN KEY (MaPhieu)
            REFERENCES dbo.PhieuMuon(MaPhieu),
        CONSTRAINT FK_MBS_BanSao FOREIGN KEY (MaBanSao)
            REFERENCES dbo.BanSao(MaBanSao),
        CONSTRAINT CK_MBS_NgayTra
            CHECK (NgayTraThucTe IS NULL OR NgayTraThucTe >= '20000101')
    );
END;
GO

IF OBJECT_ID(N'dbo.PhieuTra', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.PhieuTra (
        MaPhieuTra VARCHAR(10) NOT NULL PRIMARY KEY,
        MaPhieu VARCHAR(10) NOT NULL,
        MaNhanVien VARCHAR(10) NOT NULL,
        NgayTra DATE NOT NULL DEFAULT (CONVERT(date, GETDATE())),
        GhiChu NVARCHAR(250) NULL,
        CONSTRAINT FK_PT_PhieuMuon FOREIGN KEY (MaPhieu)
            REFERENCES dbo.PhieuMuon(MaPhieu),
        CONSTRAINT FK_PT_NhanVien FOREIGN KEY (MaNhanVien)
            REFERENCES dbo.NhanVien(MaNhanVien)
    );
END;
GO

IF OBJECT_ID(N'dbo.ChiTietTra', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.ChiTietTra (
        MaPhieuTra VARCHAR(10) NOT NULL,
        MaBanSao VARCHAR(12) NOT NULL,
        NgayTra DATE NOT NULL,
        TinhTrangTra NVARCHAR(20) NOT NULL
            CHECK (TinhTrangTra IN (N'Tốt', N'Hư hỏng', N'Mất')),
        SoNgayQuaHan INT NOT NULL DEFAULT 0 CHECK (SoNgayQuaHan >= 0),
        TienPhat DECIMAL(12,2) NOT NULL DEFAULT 0 CHECK (TienPhat >= 0),
        GhiChu NVARCHAR(200) NULL,
        CONSTRAINT PK_ChiTietTra PRIMARY KEY (MaPhieuTra, MaBanSao),
        CONSTRAINT FK_CTT_PhieuTra FOREIGN KEY (MaPhieuTra)
            REFERENCES dbo.PhieuTra(MaPhieuTra),
        CONSTRAINT FK_CTT_BanSao FOREIGN KEY (MaBanSao)
            REFERENCES dbo.BanSao(MaBanSao)
    );
END;
GO

-- Kiem tra 13 bang da duoc tao truoc khi chen du lieu mau.
IF OBJECT_ID(N'dbo.NhaXuatBan',N'U') IS NULL
 OR OBJECT_ID(N'dbo.TheLoai',N'U') IS NULL
 OR OBJECT_ID(N'dbo.TacGia',N'U') IS NULL
 OR OBJECT_ID(N'dbo.DocGia',N'U') IS NULL
 OR OBJECT_ID(N'dbo.NhanVien',N'U') IS NULL
 OR OBJECT_ID(N'dbo.Sach',N'U') IS NULL
 OR OBJECT_ID(N'dbo.Sach_TacGia',N'U') IS NULL
 OR OBJECT_ID(N'dbo.PhieuMuon',N'U') IS NULL
 OR OBJECT_ID(N'dbo.ChiTietPhieuMuon',N'U') IS NULL
 OR OBJECT_ID(N'dbo.BanSao',N'U') IS NULL
 OR OBJECT_ID(N'dbo.MuonBanSao',N'U') IS NULL
 OR OBJECT_ID(N'dbo.PhieuTra',N'U') IS NULL
 OR OBJECT_ID(N'dbo.ChiTietTra',N'U') IS NULL
BEGIN
    THROW 51002, N'Thieu bang trong buoc tao CSDL. Hay xem loi dau tien trong tab Messages.', 1;
END;
PRINT N'Da tao du 13 bang. Dang nap du lieu mau...';
GO

/*============================================================
  PHAN 3. DU LIEU MAU
  Du lieu duoc lay theo bo mau trong bao cao.
  IF NOT EXISTS giup han che chen trung khi chay lai.
============================================================*/

INSERT INTO dbo.NhaXuatBan(MaNXB,TenNXB,DiaChi,SoDienThoai,Email)
SELECT v.MaNXB,v.TenNXB,v.DiaChi,v.SoDienThoai,v.Email
FROM (VALUES
('NXB01',N'Giáo dục Việt Nam',N'Hà Nội','0240000001','giaoduc@example.com'),
('NXB02',N'Kim Đồng',N'Hà Nội','0240000002','kimdong@example.com'),
('NXB03',N'Trẻ',N'TP. Hồ Chí Minh','0280000003','tre@example.com'),
('NXB04',N'Lao động',N'Hà Nội','0240000004','laodong@example.com'),
('NXB05',N'Thông tin và Truyền thông',N'Hà Nội','0240000005','tttt@example.com'),
('NXB06',N'Khoa học và Kỹ thuật',N'Hà Nội','0240000006','khkt@example.com'),
('NXB07',N'Đại học Quốc gia',N'Hà Nội','0240000007','vnu@example.com'),
('NXB08',N'Bách khoa Hà Nội',N'Hà Nội','0240000008','hust@example.com'),
('NXB09',N'Tổng hợp TP.HCM',N'TP. Hồ Chí Minh','0280000009','tonghop@example.com'),
('NXB10',N'Văn học',N'Hà Nội','0240000010','vanhoc@example.com')
) v(MaNXB,TenNXB,DiaChi,SoDienThoai,Email)
WHERE NOT EXISTS (SELECT 1 FROM dbo.NhaXuatBan x WHERE x.MaNXB=v.MaNXB);
GO

INSERT INTO dbo.TheLoai(MaTheLoai,TenTheLoai,MoTa)
SELECT v.MaTheLoai,v.TenTheLoai,v.MoTa
FROM (VALUES
('TL01',N'Công nghệ thông tin',N'Sách lập trình, hệ thống và công nghệ.'),
('TL02',N'Cơ sở dữ liệu',N'Sách về mô hình và quản trị dữ liệu.'),
('TL03',N'Mạng máy tính',N'Sách về mạng và truyền thông.'),
('TL04',N'An toàn thông tin',N'Sách về bảo mật và an ninh mạng.'),
('TL05',N'Toán học',N'Sách toán cơ sở và ứng dụng.'),
('TL06',N'Kinh tế',N'Sách kinh tế và quản trị.'),
('TL07',N'Kỹ năng mềm',N'Sách kỹ năng học tập và làm việc.'),
('TL08',N'Văn học',N'Tác phẩm văn học.'),
('TL09',N'Ngoại ngữ',N'Sách học ngoại ngữ.'),
('TL10',N'Khoa học tự nhiên',N'Sách khoa học cơ bản.')
) v(MaTheLoai,TenTheLoai,MoTa)
WHERE NOT EXISTS (SELECT 1 FROM dbo.TheLoai x WHERE x.MaTheLoai=v.MaTheLoai);
GO

INSERT INTO dbo.TacGia(MaTacGia,TenTacGia,NamSinh,QuocTich)
SELECT v.MaTacGia,v.TenTacGia,v.NamSinh,v.QuocTich
FROM (VALUES
('TG01',N'Nguyễn Văn A',1975,N'Việt Nam'),
('TG02',N'Trần Thị B',1980,N'Việt Nam'),
('TG03',N'Lê Minh C',1972,N'Việt Nam'),
('TG04',N'Phạm Quốc D',1985,N'Việt Nam'),
('TG05',N'Hoàng Anh E',1968,N'Việt Nam'),
('TG06',N'Nguyễn Nhật Ánh',1955,N'Việt Nam'),
('TG07',N'Nguyễn Ngọc F',1978,N'Việt Nam'),
('TG08',N'Đỗ Văn G',1982,N'Việt Nam'),
('TG09',N'Bùi Hải H',1970,N'Việt Nam'),
('TG10',N'Vũ Thanh K',1988,N'Việt Nam')
) v(MaTacGia,TenTacGia,NamSinh,QuocTich)
WHERE NOT EXISTS (SELECT 1 FROM dbo.TacGia x WHERE x.MaTacGia=v.MaTacGia);
GO

INSERT INTO dbo.DocGia
(MaDocGia,HoTen,NgaySinh,GioiTinh,DiaChi,SoDienThoai,Email,LoaiDocGia,NgayDangKy,NgayHetHanThe)
SELECT v.MaDocGia,v.HoTen,v.NgaySinh,v.GioiTinh,v.DiaChi,v.SoDienThoai,
       v.Email,v.LoaiDocGia,v.NgayDangKy,v.NgayHetHanThe
FROM (VALUES
('DG001',N'Nguyễn Minh An','20060210',N'Nam',N'Hà Nội','0900000001','dg001@example.com',N'Sinh viên','20260105','20270105'),
('DG002',N'Trần Thu Hà','20050821',N'Nữ',N'Hà Nội','0900000002','dg002@example.com',N'Sinh viên','20260106','20270106'),
('DG003',N'Lê Hoàng Nam','20040412',N'Nam',N'Hưng Yên','0900000003','dg003@example.com',N'Sinh viên','20260107','20270107'),
('DG004',N'Phạm Ngọc Mai','20031102',N'Nữ',N'Hà Nam','0900000004','dg004@example.com',N'Sinh viên','20260108','20270108'),
('DG005',N'Đỗ Quang Huy','19880315',N'Nam',N'Hà Nội','0900000005','dg005@example.com',N'Giảng viên','20260109','20270109'),
('DG006',N'Vũ Thanh Tâm','19900719',N'Nữ',N'Hà Nội','0900000006','dg006@example.com',N'Giảng viên','20260110','20270110'),
('DG007',N'Bùi Đức Long','20061201',N'Nam',N'Bắc Ninh','0900000007','dg007@example.com',N'Sinh viên','20260111','20270111'),
('DG008',N'Ngô Thu Trang','19950523',N'Nữ',N'Hà Nội','0900000008','dg008@example.com',N'Nhân viên','20260112','20270112'),
('DG009',N'Đặng Hải Yến','20050909',N'Nữ',N'Nam Định','0900000009','dg009@example.com',N'Sinh viên','20260113','20270113'),
('DG010',N'Hoàng Việt Đức','20040630',N'Nam',N'Hà Nội','0900000010','dg010@example.com',N'Sinh viên','20260114','20270114')
) v(MaDocGia,HoTen,NgaySinh,GioiTinh,DiaChi,SoDienThoai,Email,LoaiDocGia,NgayDangKy,NgayHetHanThe)
WHERE NOT EXISTS (SELECT 1 FROM dbo.DocGia x WHERE x.MaDocGia=v.MaDocGia);
GO

INSERT INTO dbo.NhanVien(MaNhanVien,HoTen,SoDienThoai,Email,ChucVu,TrangThai)
SELECT v.MaNhanVien,v.HoTen,v.SoDienThoai,v.Email,v.ChucVu,v.TrangThai
FROM (VALUES
('NV01',N'Nguyễn Thị Lan','0910000001','nv01@example.com',N'Thủ thư',N'Đang làm'),
('NV02',N'Trần Văn Bình','0910000002','nv02@example.com',N'Thủ thư',N'Đang làm'),
('NV03',N'Lê Thu Phương','0910000003','nv03@example.com',N'Quản lý kho',N'Đang làm'),
('NV04',N'Phạm Văn Hải','0910000004','nv04@example.com',N'Thủ thư',N'Đang làm'),
('NV05',N'Đỗ Thị Hương','0910000005','nv05@example.com',N'Nhân viên dữ liệu',N'Đang làm'),
('NV06',N'Vũ Minh Tuấn','0910000006','nv06@example.com',N'Thủ thư',N'Đang làm'),
('NV07',N'Bùi Ngọc Anh','0910000007','nv07@example.com',N'Thủ thư',N'Đang làm'),
('NV08',N'Ngô Đức Thành','0910000008','nv08@example.com',N'Quản lý',N'Đang làm'),
('NV09',N'Đặng Thu Hà','0910000009','nv09@example.com',N'Thủ thư',N'Đang làm'),
('NV10',N'Hoàng Quang Minh','0910000010','nv10@example.com',N'Nhân viên dữ liệu',N'Đang làm')
) v(MaNhanVien,HoTen,SoDienThoai,Email,ChucVu,TrangThai)
WHERE NOT EXISTS (SELECT 1 FROM dbo.NhanVien x WHERE x.MaNhanVien=v.MaNhanVien);
GO

INSERT INTO dbo.Sach
(MaSach,TenSach,MaNXB,MaTheLoai,NamXuatBan,LanXuatBan,SoTrang,GiaSach,NgonNgu,ViTriKe,SoLuongTong,SoLuongCon,TrangThai)
SELECT v.MaSach,v.TenSach,v.MaNXB,v.MaTheLoai,v.NamXuatBan,v.LanXuatBan,
       v.SoTrang,v.GiaSach,v.NgonNgu,v.ViTriKe,v.SoLuongTong,v.SoLuongCon,v.TrangThai
FROM (VALUES
('S001',N'Nhập môn Cơ sở dữ liệu','NXB01','TL02',2023,2,320,95000,N'Tiếng Việt',N'A1-01',20,18,N'Đang lưu hành'),
('S002',N'Lập trình C cơ bản','NXB06','TL01',2022,3,410,120000,N'Tiếng Việt',N'A1-02',15,14,N'Đang lưu hành'),
('S003',N'Cấu trúc dữ liệu và giải thuật','NXB08','TL01',2024,1,500,150000,N'Tiếng Việt',N'A1-03',12,10,N'Đang lưu hành'),
('S004',N'Mạng máy tính căn bản','NXB05','TL03',2021,2,360,110000,N'Tiếng Việt',N'A2-01',10,9,N'Đang lưu hành'),
('S005',N'An toàn thông tin đại cương','NXB05','TL04',2024,1,290,130000,N'Tiếng Việt',N'A2-02',10,8,N'Đang lưu hành'),
('S006',N'Toán rời rạc','NXB07','TL05',2020,2,280,90000,N'Tiếng Việt',N'B1-01',18,18,N'Đang lưu hành'),
('S007',N'Kỹ năng học đại học','NXB04','TL07',2023,1,210,75000,N'Tiếng Việt',N'B1-02',14,13,N'Đang lưu hành'),
('S008',N'Tôi thấy hoa vàng trên cỏ xanh','NXB03','TL08',2018,5,300,85000,N'Tiếng Việt',N'C1-01',8,7,N'Đang lưu hành'),
('S009',N'Tiếng Anh chuyên ngành CNTT','NXB09','TL09',2022,1,250,105000,N'Tiếng Việt',N'C1-02',12,11,N'Đang lưu hành'),
('S010',N'Nhập môn trí tuệ nhân tạo','NXB07','TL01',2025,1,390,165000,N'Tiếng Việt',N'A1-04',9,8,N'Đang lưu hành')
) v(MaSach,TenSach,MaNXB,MaTheLoai,NamXuatBan,LanXuatBan,SoTrang,GiaSach,NgonNgu,ViTriKe,SoLuongTong,SoLuongCon,TrangThai)
WHERE NOT EXISTS (SELECT 1 FROM dbo.Sach x WHERE x.MaSach=v.MaSach);
GO

INSERT INTO dbo.Sach_TacGia(MaSach,MaTacGia,VaiTro)
SELECT v.MaSach,v.MaTacGia,v.VaiTro
FROM (VALUES
('S001','TG01',N'Tác giả chính'),('S001','TG02',N'Đồng tác giả'),
('S002','TG03',N'Tác giả chính'),('S003','TG04',N'Tác giả chính'),
('S004','TG05',N'Tác giả chính'),('S005','TG08',N'Tác giả chính'),
('S006','TG09',N'Tác giả chính'),('S007','TG02',N'Tác giả chính'),
('S008','TG06',N'Tác giả chính'),('S009','TG10',N'Tác giả chính'),
('S010','TG07',N'Tác giả chính')
) v(MaSach,MaTacGia,VaiTro)
WHERE NOT EXISTS (
    SELECT 1 FROM dbo.Sach_TacGia x
    WHERE x.MaSach=v.MaSach AND x.MaTacGia=v.MaTacGia
);
GO

/* Du lieu phieu muon cu theo bang mau trong bao cao */
INSERT INTO dbo.PhieuMuon
(MaPhieu,MaDocGia,MaNhanVien,NgayMuon,HanTra,TrangThaiPhieu,GhiChu)
SELECT v.MaPhieu,v.MaDocGia,v.MaNhanVien,v.NgayMuon,v.HanTra,v.TrangThaiPhieu,v.GhiChu
FROM (VALUES
('PM001','DG001','NV01','20260901','20260915',N'Đã trả',NULL),
('PM002','DG002','NV02','20260902','20260916',N'Đã trả',NULL),
('PM003','DG003','NV01','20260905','20260919',N'Đang mượn',NULL),
('PM004','DG004','NV04','20260907','20260921',N'Đang mượn',NULL),
('PM005','DG005','NV03','20260908','20260922',N'Đã trả',N'Mượn phục vụ giảng dạy'),
('PM006','DG006','NV06','20260910','20260924',N'Đã trả',NULL),
('PM007','DG007','NV07','20260912','20260926',N'Đang mượn',NULL),
('PM008','DG008','NV08','20260915','20260929',N'Đã trả',NULL),
('PM009','DG009','NV09','20260918','20261002',N'Quá hạn',N'Chưa trả đúng hạn'),
('PM010','DG010','NV10','20260920','20261004',N'Đang mượn',NULL)
) v(MaPhieu,MaDocGia,MaNhanVien,NgayMuon,HanTra,TrangThaiPhieu,GhiChu)
WHERE NOT EXISTS (SELECT 1 FROM dbo.PhieuMuon x WHERE x.MaPhieu=v.MaPhieu);
GO

INSERT INTO dbo.ChiTietPhieuMuon(MaPhieu,MaSach,SoLuongMuon,NgayTra,TinhTrangTra,GhiChu)
SELECT v.MaPhieu,v.MaSach,v.SoLuongMuon,v.NgayTra,v.TinhTrangTra,v.GhiChu
FROM (VALUES
('PM001','S001',1,'20260910',N'Tốt',NULL),
('PM002','S002',1,'20260914',N'Tốt',NULL),
('PM003','S003',1,NULL,NULL,NULL),
('PM004','S005',1,NULL,NULL,NULL),
('PM005','S004',1,'20260920',N'Tốt',NULL),
('PM006','S006',1,'20260922',N'Tốt',NULL),
('PM007','S007',1,NULL,NULL,NULL),
('PM008','S008',1,'20260925',N'Trầy xước',N'Ghi nhận khi nhận lại'),
('PM009','S009',1,NULL,NULL,N'Quá hạn'),
('PM010','S010',1,NULL,NULL,NULL)
) v(MaPhieu,MaSach,SoLuongMuon,NgayTra,TinhTrangTra,GhiChu)
WHERE NOT EXISTS (
    SELECT 1 FROM dbo.ChiTietPhieuMuon x
    WHERE x.MaPhieu=v.MaPhieu AND x.MaSach=v.MaSach
);
GO

/* 10 ban sao minh hoa theo muc 7.1 cua bao cao */
INSERT INTO dbo.BanSao(MaBanSao,MaSach,TinhTrang,TrangThai,NgayNhap)
SELECT v.MaBanSao,v.MaSach,v.TinhTrang,v.TrangThai,v.NgayNhap
FROM (VALUES
('BS001','S001',N'Tốt',N'Sẵn sàng','20260801'),
('BS002','S001',N'Tốt',N'Sẵn sàng','20260801'),
('BS003','S001',N'Tốt',N'Sẵn sàng','20260801'),
('BS004','S002',N'Tốt',N'Sẵn sàng','20260802'),
('BS005','S002',N'Tốt',N'Sẵn sàng','20260802'),
('BS006','S003',N'Tốt',N'Sẵn sàng','20260803'),
('BS007','S003',N'Tốt',N'Sẵn sàng','20260803'),
('BS008','S004',N'Tốt',N'Sẵn sàng','20260804'),
('BS009','S005',N'Tốt',N'Sẵn sàng','20260804'),
('BS010','S006',N'Tốt',N'Sẵn sàng','20260805')
) v(MaBanSao,MaSach,TinhTrang,TrangThai,NgayNhap)
WHERE NOT EXISTS (SELECT 1 FROM dbo.BanSao x WHERE x.MaBanSao=v.MaBanSao);
GO

/*============================================================
  PHAN 4. CAC THU TUC NGHIEP VU MUON SACH
============================================================*/

CREATE OR ALTER PROCEDURE dbo.sp_KiemTraDuDieuKienMuon
    @MaDocGia VARCHAR(10),
    @MaBanSao VARCHAR(12)
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (
        SELECT 1 FROM dbo.DocGia
        WHERE MaDocGia=@MaDocGia
          AND NgayHetHanThe >= CONVERT(date,GETDATE())
    )
        THROW 50001, N'Độc giả không tồn tại hoặc thẻ đã hết hạn.', 1;

    IF NOT EXISTS (
        SELECT 1 FROM dbo.BanSao
        WHERE MaBanSao=@MaBanSao
          AND TrangThai=N'Sẵn sàng'
          AND TinhTrang=N'Tốt'
    )
        THROW 50002, N'Bản sao không sẵn sàng để cho mượn.', 1;

    SELECT N'Đủ điều kiện mượn' AS KetQua;
END;
GO

CREATE OR ALTER PROCEDURE dbo.sp_LapPhieuMuonMotBanSao
    @MaPhieu VARCHAR(10),
    @MaDocGia VARCHAR(10),
    @MaNhanVien VARCHAR(10),
    @MaBanSao VARCHAR(12),
    @NgayMuon DATE,
    @HanTra DATE
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRAN;

        IF @HanTra < @NgayMuon
            THROW 50003, N'Hạn trả không hợp lệ.', 1;

        IF NOT EXISTS (
            SELECT 1 FROM dbo.DocGia
            WHERE MaDocGia=@MaDocGia
              AND NgayHetHanThe>=@NgayMuon
        )
            THROW 50004, N'Thẻ độc giả không hợp lệ.', 1;

        IF NOT EXISTS (
            SELECT 1 FROM dbo.NhanVien
            WHERE MaNhanVien=@MaNhanVien AND TrangThai=N'Đang làm'
        )
            THROW 50006, N'Nhân viên không tồn tại hoặc không ở trạng thái làm việc.', 1;

        IF NOT EXISTS (
            SELECT 1 FROM dbo.BanSao WITH (UPDLOCK,HOLDLOCK)
            WHERE MaBanSao=@MaBanSao
              AND TrangThai=N'Sẵn sàng'
              AND TinhTrang=N'Tốt'
        )
            THROW 50005, N'Bản sao không còn sẵn sàng.', 1;

        IF EXISTS (SELECT 1 FROM dbo.PhieuMuon WHERE MaPhieu=@MaPhieu)
            THROW 50007, N'Mã phiếu mượn đã tồn tại.', 1;

        INSERT INTO dbo.PhieuMuon
            (MaPhieu,MaDocGia,MaNhanVien,NgayMuon,HanTra,TrangThaiPhieu)
        VALUES
            (@MaPhieu,@MaDocGia,@MaNhanVien,@NgayMuon,@HanTra,N'Đang mượn');

        INSERT INTO dbo.MuonBanSao(MaPhieu,MaBanSao,NgayTraDuKien)
        VALUES(@MaPhieu,@MaBanSao,@HanTra);

        UPDATE dbo.BanSao
        SET TrangThai=N'Đang mượn'
        WHERE MaBanSao=@MaBanSao;

        COMMIT;
        SELECT N'Lập phiếu mượn thành công.' AS KetQua, @MaPhieu AS MaPhieu;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK;
        THROW;
    END CATCH
END;
GO

/*============================================================
  PHAN 5. THU TUC TRA SACH VA TINH TIEN PHAT
  Muc phat: 5.000 dong/ngay/ban sao qua han.
  Khong tu dat them tien phat cho sach hu hong/mat.
============================================================*/

CREATE OR ALTER PROCEDURE dbo.sp_TraMotBanSao
    @MaPhieuTra VARCHAR(10),
    @MaPhieu VARCHAR(10),
    @MaNhanVien VARCHAR(10),
    @MaBanSao VARCHAR(12),
    @NgayTra DATE,
    @TinhTrangTra NVARCHAR(20),
    @GhiChu NVARCHAR(200)=NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRAN;

        IF @TinhTrangTra NOT IN (N'Tốt',N'Hư hỏng',N'Mất')
            THROW 50101, N'Tình trạng trả không hợp lệ.', 1;

        IF EXISTS (SELECT 1 FROM dbo.PhieuTra WHERE MaPhieuTra=@MaPhieuTra)
            THROW 50102, N'Mã phiếu trả đã tồn tại.', 1;

        IF NOT EXISTS (
            SELECT 1 FROM dbo.MuonBanSao WITH (UPDLOCK,HOLDLOCK)
            WHERE MaPhieu=@MaPhieu
              AND MaBanSao=@MaBanSao
              AND NgayTraThucTe IS NULL
        )
            THROW 50103, N'Không tìm thấy bản sao đang được mượn trong phiếu này.', 1;

        IF NOT EXISTS (
            SELECT 1 FROM dbo.NhanVien
            WHERE MaNhanVien=@MaNhanVien AND TrangThai=N'Đang làm'
        )
            THROW 50104, N'Nhân viên không hợp lệ.', 1;

        INSERT INTO dbo.PhieuTra(MaPhieuTra,MaPhieu,MaNhanVien,NgayTra,GhiChu)
        VALUES(@MaPhieuTra,@MaPhieu,@MaNhanVien,@NgayTra,@GhiChu);

        INSERT INTO dbo.ChiTietTra
            (MaPhieuTra,MaBanSao,NgayTra,TinhTrangTra,SoNgayQuaHan,TienPhat,GhiChu)
        SELECT
            @MaPhieuTra,
            m.MaBanSao,
            @NgayTra,
            @TinhTrangTra,
            CASE WHEN DATEDIFF(DAY,m.NgayTraDuKien,@NgayTra)>0
                 THEN DATEDIFF(DAY,m.NgayTraDuKien,@NgayTra) ELSE 0 END,
            CASE WHEN DATEDIFF(DAY,m.NgayTraDuKien,@NgayTra)>0
                 THEN DATEDIFF(DAY,m.NgayTraDuKien,@NgayTra)*5000 ELSE 0 END,
            @GhiChu
        FROM dbo.MuonBanSao m
        WHERE m.MaPhieu=@MaPhieu
          AND m.MaBanSao=@MaBanSao
          AND m.NgayTraThucTe IS NULL;

        UPDATE dbo.MuonBanSao
        SET NgayTraThucTe=@NgayTra
        WHERE MaPhieu=@MaPhieu
          AND MaBanSao=@MaBanSao
          AND NgayTraThucTe IS NULL;

        UPDATE bs
        SET TinhTrang=@TinhTrangTra,
            TrangThai=CASE
                WHEN @TinhTrangTra=N'Tốt' THEN N'Sẵn sàng'
                WHEN @TinhTrangTra=N'Hư hỏng' THEN N'Hư hỏng'
                WHEN @TinhTrangTra=N'Mất' THEN N'Mất'
            END
        FROM dbo.BanSao bs
        WHERE bs.MaBanSao=@MaBanSao;

        UPDATE pm
        SET TrangThaiPhieu=CASE
            WHEN EXISTS (
                SELECT 1 FROM dbo.MuonBanSao m
                WHERE m.MaPhieu=pm.MaPhieu AND m.NgayTraThucTe IS NULL
            ) THEN N'Đang mượn'
            ELSE N'Đã trả'
        END
        FROM dbo.PhieuMuon pm
        WHERE pm.MaPhieu=@MaPhieu;

        COMMIT;

        SELECT ct.MaPhieuTra,ct.MaBanSao,ct.SoNgayQuaHan,ct.TienPhat,
               ct.TinhTrangTra
        FROM dbo.ChiTietTra ct
        WHERE ct.MaPhieuTra=@MaPhieuTra
          AND ct.MaBanSao=@MaBanSao;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK;
        THROW;
    END CATCH
END;
GO

/*============================================================
  PHAN 6. VIEW VA INDEX PHUC VU BAO CAO
============================================================*/

CREATE OR ALTER VIEW dbo.vw_TinhTrangBanSao
AS
SELECT bs.MaBanSao,s.MaSach,s.TenSach,s.ViTriKe,
       bs.TinhTrang,bs.TrangThai
FROM dbo.BanSao bs
JOIN dbo.Sach s ON bs.MaSach=s.MaSach;
GO

CREATE OR ALTER VIEW dbo.vw_TongHopTienPhat
AS
SELECT pt.MaPhieuTra,pt.MaPhieu,dg.MaDocGia,dg.HoTen,
       pt.NgayTra,SUM(ct.TienPhat) AS TongTienPhat
FROM dbo.PhieuTra pt
JOIN dbo.PhieuMuon pm ON pt.MaPhieu=pm.MaPhieu
JOIN dbo.DocGia dg ON pm.MaDocGia=dg.MaDocGia
JOIN dbo.ChiTietTra ct ON pt.MaPhieuTra=ct.MaPhieuTra
GROUP BY pt.MaPhieuTra,pt.MaPhieu,dg.MaDocGia,dg.HoTen,pt.NgayTra;
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name=N'IX_MuonBanSao_NgayTraDuKien' AND object_id=OBJECT_ID(N'dbo.MuonBanSao'))
    CREATE INDEX IX_MuonBanSao_NgayTraDuKien
    ON dbo.MuonBanSao(NgayTraDuKien)
    INCLUDE(MaPhieu,MaBanSao,NgayTraThucTe);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name=N'IX_BanSao_TrangThai' AND object_id=OBJECT_ID(N'dbo.BanSao'))
    CREATE INDEX IX_BanSao_TrangThai
    ON dbo.BanSao(TrangThai,MaSach);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name=N'IX_PhieuMuon_MaDocGia_NgayMuon' AND object_id=OBJECT_ID(N'dbo.PhieuMuon'))
    CREATE INDEX IX_PhieuMuon_MaDocGia_NgayMuon
    ON dbo.PhieuMuon(MaDocGia,NgayMuon);
GO

/*============================================================
  PHAN 7. CAC TRUY VAN BAO CAO - CHAY RIENG TUNG KHOI
============================================================*/

-- 7.1. Danh sach sach
SELECT s.MaSach,s.TenSach,tl.TenTheLoai,nxb.TenNXB,
       s.NamXuatBan,s.GiaSach,s.SoLuongTong,s.SoLuongCon,s.TrangThai
FROM dbo.Sach s
JOIN dbo.TheLoai tl ON s.MaTheLoai=tl.MaTheLoai
JOIN dbo.NhaXuatBan nxb ON s.MaNXB=nxb.MaNXB
ORDER BY s.MaSach;
GO

-- 7.2. Sach theo tac gia
SELECT s.MaSach,s.TenSach,tg.TenTacGia,stg.VaiTro
FROM dbo.Sach s
JOIN dbo.Sach_TacGia stg ON s.MaSach=stg.MaSach
JOIN dbo.TacGia tg ON stg.MaTacGia=tg.MaTacGia
ORDER BY s.MaSach,tg.TenTacGia;
GO

-- 7.3. Doc gia va lich su muon
SELECT dg.MaDocGia,dg.HoTen,pm.MaPhieu,pm.NgayMuon,pm.HanTra,
       pm.TrangThaiPhieu,COUNT(m.MaBanSao) AS SoBanSao
FROM dbo.DocGia dg
LEFT JOIN dbo.PhieuMuon pm ON dg.MaDocGia=pm.MaDocGia
LEFT JOIN dbo.MuonBanSao m ON pm.MaPhieu=m.MaPhieu
GROUP BY dg.MaDocGia,dg.HoTen,pm.MaPhieu,pm.NgayMuon,pm.HanTra,pm.TrangThaiPhieu
ORDER BY dg.MaDocGia,pm.NgayMuon DESC;
GO

-- 7.4. Kiem tra han the doc gia
SELECT MaDocGia,HoTen,NgayHetHanThe,
       CASE WHEN NgayHetHanThe>=CONVERT(date,GETDATE())
            THEN N'Còn hạn' ELSE N'Hết hạn' END AS TinhTrangThe
FROM dbo.DocGia
ORDER BY MaDocGia;
GO

-- 7.5. Thong ke so luong sach theo the loai
SELECT tl.MaTheLoai,tl.TenTheLoai,
       COUNT(DISTINCT s.MaSach) AS SoDauSach,
       COUNT(bs.MaBanSao) AS TongBanSao
FROM dbo.TheLoai tl
LEFT JOIN dbo.Sach s ON tl.MaTheLoai=s.MaTheLoai
LEFT JOIN dbo.BanSao bs ON s.MaSach=bs.MaSach
GROUP BY tl.MaTheLoai,tl.TenTheLoai
ORDER BY SoDauSach DESC;
GO

-- 7.6. Thong ke sach theo nha xuat ban
SELECT nxb.MaNXB,nxb.TenNXB,
       COUNT(DISTINCT s.MaSach) AS SoDauSach,
       COUNT(bs.MaBanSao) AS SoBanSao
FROM dbo.NhaXuatBan nxb
LEFT JOIN dbo.Sach s ON nxb.MaNXB=s.MaNXB
LEFT JOIN dbo.BanSao bs ON s.MaSach=bs.MaSach
GROUP BY nxb.MaNXB,nxb.TenNXB
ORDER BY SoDauSach DESC;
GO

-- 7.7. So luot muon theo thang (dem phieu va ban sao)
SELECT YEAR(pm.NgayMuon) AS Nam,MONTH(pm.NgayMuon) AS Thang,
       COUNT(DISTINCT pm.MaPhieu) AS SoPhieuMuon,
       COUNT(m.MaBanSao) AS SoBanSaoDuocMuon
FROM dbo.PhieuMuon pm
LEFT JOIN dbo.MuonBanSao m ON pm.MaPhieu=m.MaPhieu
GROUP BY YEAR(pm.NgayMuon),MONTH(pm.NgayMuon)
ORDER BY Nam,Thang;
GO

-- 7.8. Doc gia muon nhieu nhat
SELECT TOP 1 WITH TIES dg.MaDocGia,dg.HoTen,
       COUNT(m.MaBanSao) AS TongLuotMuon
FROM dbo.DocGia dg
JOIN dbo.PhieuMuon pm ON dg.MaDocGia=pm.MaDocGia
JOIN dbo.MuonBanSao m ON pm.MaPhieu=m.MaPhieu
GROUP BY dg.MaDocGia,dg.HoTen
ORDER BY COUNT(m.MaBanSao) DESC;
GO

-- 7.9. Sach duoc muon nhieu nhat
SELECT TOP 10 s.MaSach,s.TenSach,COUNT(m.MaBanSao) AS SoLuotMuon
FROM dbo.Sach s
JOIN dbo.BanSao bs ON s.MaSach=bs.MaSach
JOIN dbo.MuonBanSao m ON bs.MaBanSao=m.MaBanSao
GROUP BY s.MaSach,s.TenSach
ORDER BY SoLuotMuon DESC;
GO

-- 7.10. Tong tien phat theo thang
SELECT YEAR(pt.NgayTra) AS Nam,MONTH(pt.NgayTra) AS Thang,
       SUM(ct.TienPhat) AS TongTienPhat
FROM dbo.PhieuTra pt
JOIN dbo.ChiTietTra ct ON pt.MaPhieuTra=ct.MaPhieuTra
GROUP BY YEAR(pt.NgayTra),MONTH(pt.NgayTra)
ORDER BY Nam,Thang;
GO

-- 7.11. Danh sach ban sao dang duoc muon
SELECT dg.MaDocGia,dg.HoTen,pm.MaPhieu,bs.MaBanSao,s.TenSach,
       pm.NgayMuon,m.NgayTraDuKien
FROM dbo.DocGia dg
JOIN dbo.PhieuMuon pm ON dg.MaDocGia=pm.MaDocGia
JOIN dbo.MuonBanSao m ON pm.MaPhieu=m.MaPhieu
JOIN dbo.BanSao bs ON m.MaBanSao=bs.MaBanSao
JOIN dbo.Sach s ON bs.MaSach=s.MaSach
WHERE m.NgayTraThucTe IS NULL
ORDER BY dg.HoTen,m.NgayTraDuKien;
GO

-- 7.12. Danh sach ban sao qua han
SELECT dg.MaDocGia,dg.HoTen,pm.MaPhieu,bs.MaBanSao,s.TenSach,
       m.NgayTraDuKien,
       DATEDIFF(DAY,m.NgayTraDuKien,CONVERT(date,GETDATE())) AS SoNgayQuaHan,
       DATEDIFF(DAY,m.NgayTraDuKien,CONVERT(date,GETDATE()))*5000 AS TienPhatTamTinh
FROM dbo.MuonBanSao m
JOIN dbo.PhieuMuon pm ON m.MaPhieu=pm.MaPhieu
JOIN dbo.DocGia dg ON pm.MaDocGia=dg.MaDocGia
JOIN dbo.BanSao bs ON m.MaBanSao=bs.MaBanSao
JOIN dbo.Sach s ON bs.MaSach=s.MaSach
WHERE m.NgayTraThucTe IS NULL
  AND m.NgayTraDuKien<CONVERT(date,GETDATE())
ORDER BY m.NgayTraDuKien;
GO

-- 7.13. Danh sach sach mat
SELECT bs.MaBanSao,s.MaSach,s.TenSach,bs.NgayNhap,
       bs.TinhTrang,bs.TrangThai,bs.GhiChu
FROM dbo.BanSao bs
JOIN dbo.Sach s ON bs.MaSach=s.MaSach
WHERE bs.TrangThai=N'Mất' OR bs.TinhTrang=N'Mất'
ORDER BY s.TenSach,bs.MaBanSao;
GO

-- 7.14. Bao cao doc gia muon qua han
SELECT dg.MaDocGia,dg.HoTen,dg.SoDienThoai,
       COUNT(m.MaBanSao) AS SoCuonQuaHan,
       SUM(DATEDIFF(DAY,m.NgayTraDuKien,CONVERT(date,GETDATE()))) AS TongNgayQuaHan
FROM dbo.DocGia dg
JOIN dbo.PhieuMuon pm ON dg.MaDocGia=pm.MaDocGia
JOIN dbo.MuonBanSao m ON pm.MaPhieu=m.MaPhieu
WHERE m.NgayTraThucTe IS NULL
  AND m.NgayTraDuKien<CONVERT(date,GETDATE())
GROUP BY dg.MaDocGia,dg.HoTen,dg.SoDienThoai
ORDER BY SoCuonQuaHan DESC,TongNgayQuaHan DESC;
GO

-- 7.15. Kiem tra tinh nhat quan: chua tra nhung ban sao khong o trang thai Dang muon
SELECT m.MaPhieu,m.MaBanSao,bs.TrangThai
FROM dbo.MuonBanSao m
JOIN dbo.BanSao bs ON m.MaBanSao=bs.MaBanSao
WHERE m.NgayTraThucTe IS NULL
  AND bs.TrangThai<>N'Đang mượn';
GO

-- 7.16. Kiem tra tong tien phat chi tiet va view
SELECT
    (SELECT ISNULL(SUM(TienPhat),0) FROM dbo.ChiTietTra) AS TongPhatChiTiet,
    (SELECT ISNULL(SUM(TongTienPhat),0) FROM dbo.vw_TongHopTienPhat) AS TongPhatTheoView;
GO

-- 7.17. Xem cac view
SELECT * FROM dbo.vw_TinhTrangBanSao ORDER BY TenSach,MaBanSao;
GO
SELECT * FROM dbo.vw_TongHopTienPhat ORDER BY NgayTra DESC;
GO

/*============================================================
  PHAN 8. KIEM TRA CAC BANG VA DU LIEU SAU KHI TAO
============================================================*/

SELECT TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_TYPE='BASE TABLE'
ORDER BY TABLE_NAME;
GO

SELECT 'NhaXuatBan' AS TenBang,COUNT(*) AS SoDong FROM dbo.NhaXuatBan
UNION ALL SELECT 'TheLoai',COUNT(*) FROM dbo.TheLoai
UNION ALL SELECT 'TacGia',COUNT(*) FROM dbo.TacGia
UNION ALL SELECT 'DocGia',COUNT(*) FROM dbo.DocGia
UNION ALL SELECT 'NhanVien',COUNT(*) FROM dbo.NhanVien
UNION ALL SELECT 'Sach',COUNT(*) FROM dbo.Sach
UNION ALL SELECT 'Sach_TacGia',COUNT(*) FROM dbo.Sach_TacGia
UNION ALL SELECT 'PhieuMuon',COUNT(*) FROM dbo.PhieuMuon
UNION ALL SELECT 'ChiTietPhieuMuon',COUNT(*) FROM dbo.ChiTietPhieuMuon
UNION ALL SELECT 'BanSao',COUNT(*) FROM dbo.BanSao
UNION ALL SELECT 'MuonBanSao',COUNT(*) FROM dbo.MuonBanSao
UNION ALL SELECT 'PhieuTra',COUNT(*) FROM dbo.PhieuTra
UNION ALL SELECT 'ChiTietTra',COUNT(*) FROM dbo.ChiTietTra;
GO

/*
============================================================
  HUONG DAN KIEM THU NGHIEP VU (KHONG TU DONG CHAY)
============================================================

1. Kiem tra dieu kien muon:
   EXEC dbo.sp_KiemTraDuDieuKienMuon 'DG001','BS001';

2. Tao phieu muon thu:
   EXEC dbo.sp_LapPhieuMuonMotBanSao
       @MaPhieu='PM_DEMO01',
       @MaDocGia='DG001',
       @MaNhanVien='NV01',
       @MaBanSao='BS001',
       @NgayMuon='2026-11-16',
       @HanTra='2026-11-30';

3. Tra ban sao vua muon:
   EXEC dbo.sp_TraMotBanSao
       @MaPhieuTra='PT_DEMO01',
       @MaPhieu='PM_DEMO01',
       @MaNhanVien='NV01',
       @MaBanSao='BS001',
       @NgayTra='2026-12-03',
       @TinhTrangTra=N'Tốt',
       @GhiChu=N'Trả sách kiểm thử';

   Neu han tra la 30/11/2026 va ngay tra la 03/12/2026:
   qua han 3 ngay, tien phat 15.000 dong.

4. Xem ket qua:
   SELECT * FROM dbo.PhieuMuon WHERE MaPhieu='PM_DEMO01';
   SELECT * FROM dbo.MuonBanSao WHERE MaPhieu='PM_DEMO01';
   SELECT * FROM dbo.PhieuTra WHERE MaPhieuTra='PT_DEMO01';
   SELECT * FROM dbo.ChiTietTra WHERE MaPhieuTra='PT_DEMO01';
   SELECT * FROM dbo.BanSao WHERE MaBanSao='BS001';

Luu y:
- Bo du lieu mau trong bao cao co 10 ban sao BS001-BS010.
- Cac phieu PM001-PM010 la du lieu giao dich mau cua mo hinh cu.
  Bang MuonBanSao duoc dung cho nghiep vu theo tung ban sao moi.
- Khong tu dong chay giao dich demo khi khoi tao CSDL, tranh lam thay doi du lieu.
- CSDL mau co the chay cac truy van danh muc/thong ke ngay; cac bao cao
  theo ban sao se co du lieu sau khi thuc hien cac giao dich muon/tra.
============================================================
*/


/*============================================================
  KIEM TRA CUOI CUNG - CAC BANG BAT BUOC PHAI TON TAI
============================================================*/
USE HeThongQuanLyThuVien;
GO

IF OBJECT_ID(N'dbo.BanSao', N'U') IS NULL
   OR OBJECT_ID(N'dbo.DocGia', N'U') IS NULL
   OR OBJECT_ID(N'dbo.NhaXuatBan', N'U') IS NULL
   OR OBJECT_ID(N'dbo.MuonBanSao', N'U') IS NULL
   OR OBJECT_ID(N'dbo.ChiTietTra', N'U') IS NULL
BEGIN
    THROW 51001, N'Khoi tao chua day du. Hay xem tab Messages de tim loi xuat hien truoc dong nay.', 1;
END;

SELECT
    DB_NAME() AS CoSoDuLieu,
    (SELECT COUNT(*) FROM sys.tables WHERE is_ms_shipped = 0) AS TongSoBang,
    (SELECT COUNT(*) FROM dbo.BanSao) AS SoBanSao,
    (SELECT COUNT(*) FROM dbo.DocGia) AS SoDocGia,
    (SELECT COUNT(*) FROM dbo.NhaXuatBan) AS SoNhaXuatBan;

PRINT N'KHOI TAO HOAN TAT: Cac bang bat buoc da ton tai trong HeThongQuanLyThuVien.';
GO

PRINT N'HOAN TAT: HeThongQuanLyThuVien da duoc tao va kiem tra.';
GO
