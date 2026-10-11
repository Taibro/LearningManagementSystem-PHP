import 'package:flutter/material.dart';

final List<Map<String, dynamic>> mockStudents = [
  {'id':'SV01','name':'Kiều Tấn Phát',    'mssv':'2001230773','class':'14DHTH13','major':'CNTT','status':'active', 'gpa':3.6,'email':'ktp@sinh.huit.edu.vn','phone':'0901111111'},
  {'id':'SV02','name':'Âu Gia Quốc',      'mssv':'2001230775','class':'14DHTH12','major':'CNTT','status':'active', 'gpa':3.2,'email':'agq@sinh.huit.edu.vn','phone':'0901222222'},
  {'id':'SV03','name':'Cao Đức Mạnh',     'mssv':'2001230777','class':'14DHTH12','major':'CNTT','status':'warning','gpa':2.1,'email':'cdm@sinh.huit.edu.vn','phone':'0901333333'},
  {'id':'SV04','name':'Nguyễn Thị Mai',   'mssv':'2001230778','class':'14DHTH13','major':'CNTT','status':'active', 'gpa':3.8,'email':'ntm@sinh.huit.edu.vn','phone':'0901444444'},
  {'id':'SV05','name':'Phan Trọng Nghiêm','mssv':'2001230779','class':'12DHBM05','major':'KHMT','status':'locked', 'gpa':1.4,'email':'ptn@sinh.huit.edu.vn','phone':'0901555555'},
  {'id':'SV06','name':'Trần Minh Khoa',   'mssv':'2001230780','class':'14DHTH13','major':'CNTT','status':'active', 'gpa':3.4,'email':'tmk@sinh.huit.edu.vn','phone':'0901666666'},
  {'id':'SV07','name':'Lê Thu Hà',        'mssv':'2001230781','class':'14DHTH14','major':'HTTT','status':'active', 'gpa':3.7,'email':'lth@sinh.huit.edu.vn','phone':'0901777777'},
];

final List<Map<String, dynamic>> mockLecturers = [
  {'id':'GV01','name':'Nguyễn Văn A','code':'GV001','department':'CNTT','degree':'Tiến sĩ', 'rank':'Giảng viên chính','classes':5,'status':'active', 'email':'gv001@huit.edu.vn','phone':'0901234567'},
  {'id':'GV02','name':'Trần Thị B',  'code':'GV002','department':'CNTT','degree':'Thạc sĩ', 'rank':'Giảng viên',      'classes':4,'status':'active', 'email':'gv002@huit.edu.vn','phone':'0902234567'},
  {'id':'GV03','name':'Lê Văn C',    'code':'GV003','department':'HTTT','degree':'Tiến sĩ', 'rank':'Giảng viên chính','classes':3,'status':'active', 'email':'gv003@huit.edu.vn','phone':'0903234567'},
  {'id':'GV04','name':'Phạm Thị D',  'code':'GV004','department':'KHMT','degree':'Thạc sĩ', 'rank':'Giảng viên',      'classes':6,'status':'active', 'email':'gv004@huit.edu.vn','phone':'0904234567'},
  {'id':'GV05','name':'Hoàng Văn E', 'code':'GV005','department':'CNTT','degree':'Tiến sĩ', 'rank':'Phó giáo sư',    'classes':2,'status':'inactive','email':'gv005@huit.edu.vn','phone':'0905234567'},
];
