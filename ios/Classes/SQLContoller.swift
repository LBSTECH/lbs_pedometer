//
//  SQLContoller.swift
//  lbs_pedometer
//
//  Created by Maximilian on 2020/03/20.
//

import Foundation
import SQLite3

class SQLController : NSObject{
    static let instance = SQLController();
    private var dataBase : OpaquePointer?
    
    override private init() {
        super.init()
        openDB()
    }
    
    
    /// DB 초기화 하는 작업 - DB connection.
    private func openDB(){
        let fileURL = try! FileManager.default.url(
            for: .documentDirectory, in: .userDomainMask,
            appropriateFor: nil, create: false).appendingPathComponent("TestDatabase.sqlite")
        
        if sqlite3_open(fileURL.path, &dataBase) != SQLITE_OK {
            print("DB 열기 실패");
        }
        print("DB 오픈 성공");
        if sqlite3_exec(dataBase,
          "CREATE TABLE IF NOT EXISTS step (" +
            "id INTEGER PRIMARY KEY AUTOINCREMENT, " +
            "latitude REAL, " +
            "longitude REAL)",
          nil,
          nil,
          nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(dataBase)!)
            print("error creating table: \(errmsg)")
        }else {
            if !UserDefaults.standard.bool(forKey: "isRunning") {
                // 위치 추적이 끝나지 않은 경우
                cleanDB()
            }
        }
    }
    
    
    /// 현제 DB가 사용가능한 상태인지 확인하는 메서드
    func isAvailable() -> Bool{
        if dataBase == nil {
            print("DB가 제대로 연결되지 않아 사용이 불가능함")
            return false
        }else{
            return true
        }
    }
    
    
    /// 만들어진 DB에 요소를 전달받아 insert하는 메서드.
    /// - Parameters:
    ///   - lat: 위도
    ///   - lng: 경도
    func insert(lat:Double, lng:Double){
        let insertQuery = "INSERT INTO step (latitude, longitude) VALUES (?, ?)";
        
        var insertStatement : OpaquePointer?
        if sqlite3_prepare(dataBase, insertQuery, -1, &insertStatement, nil) == SQLITE_OK {
            sqlite3_bind_double(insertStatement, 1, lat)
            sqlite3_bind_double(insertStatement, 2, lng)
            
            if sqlite3_step(insertStatement) == SQLITE_DONE {
              print("\nSuccessfully inserted row.")
            } else {
              print("\nCould not insert row.")
            }
        }else {
            let errmsg = String(cString: sqlite3_errmsg(dataBase)!)
            print("error preparing insert:v1 \(errmsg)")
            print("\nINSERT statement is not prepared.")
        }
        sqlite3_finalize(insertStatement)
    }

    
    /// 저장된 데이터 모두 가져와서 Dictionary 의 List로 반환.
    func selctAll() -> [[Double]]{
        let selectString = "SELECT * FROM step;"
        var selectStatement: OpaquePointer?
        var result : [[Double]] = []
        
        if sqlite3_prepare_v2(dataBase, selectString, -1, &selectStatement, nil) != SQLITE_OK {
            print("문법상의 에러 발생")
            return []
        }
        while sqlite3_step(selectStatement) == SQLITE_ROW {
            let latitude = sqlite3_column_double(selectStatement, 1)
            let longitude = sqlite3_column_double(selectStatement, 2)
            result.append([
                latitude, longitude,
            ])
        }
        return result
    }
    
    
    /// DB 모두 비우기
    func cleanDB () {
        let deleteString = "DELETE FROM step;"
        var deleteStatement : OpaquePointer?
        if sqlite3_prepare_v2(dataBase, deleteString, -1, &deleteStatement, nil) != SQLITE_OK {
            print("문법상의 오류 발생")
        }
        if sqlite3_step(deleteStatement) == SQLITE_DONE {
            print("DELETE 문 성공")
        }else {
            print("DELETE 문 반영 안됨")
        }
    }
}
