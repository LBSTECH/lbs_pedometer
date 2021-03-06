package plugin.net.lbstech.lbs_pedometer;

import android.content.ContentValues;
import android.content.Context;
import android.database.Cursor;
import android.database.sqlite.SQLiteDatabase;
import android.util.Log;

import java.util.ArrayList;
import java.util.Calendar;
import java.util.HashMap;

class SQLController {
    private final String TABLE_NAME = "pedometer";

    private static SQLController instance;
    private final SQLiteDatabase database;
    private static boolean isActivate = false;

    static SQLController getInstance(Context context){
        return instance == null
                ? instance = new SQLController(context)
                : instance;
    }

    private SQLController(Context context){
        // connect database
        final String DATABASE_NAME = "sensor";
        database = context.openOrCreateDatabase(DATABASE_NAME, Context.MODE_PRIVATE, null);
        // create table
        database.execSQL(
                "CREATE TABLE IF NOT EXISTS "
                + TABLE_NAME
                + "(_id INTEGER PRIMARY KEY AUTOINCREMENT, " +
                        "latitude REAL, " +
                        "longitude REAL)");

        // 비정상 종료시 남아있는 데이터 삭제
        clear();
    }

    /**
     * SQLite DB에 insert 하는 메서드
     *
     * @param latitude 위도
     * @param longitude 경도
     */
    void insert(double latitude, double longitude){
        synchronized (database){
            if( !isActivate ) isActivate = true;
            ContentValues values = new ContentValues();
            values.put("latitude", latitude);
            values.put("longitude", longitude);
            database.insert(TABLE_NAME, null, values);
        }
    }

    /**
     *  테이블 데이터 삭제.
     */
    void clear(){
        synchronized (database){
            if (isActivate) isActivate = false;
            database.delete(TABLE_NAME, null, null);
        }
    }

    /**
     * 기록을 시작하고 App 을 종료한 이후 다시 시작하면 해당 메서드를 통해서 이전의 기록 모두 불러온다.
     *
     * @return 전체 쿼리 결과를 담은 list
     */
    ArrayList<double[]> getHistory(){
        if ( !isActivate ) return null;

        Cursor cursor;
        synchronized (database){
            cursor = database.query(TABLE_NAME, null,
                null, null,
                null, null, "_id");
        }
        if (cursor != null){
            ArrayList<double[]> result = new ArrayList<>();
            while(cursor.moveToNext()){
                double[] row = new double[]{
                        cursor.getDouble(cursor.getColumnIndex("latitude")),
                        cursor.getDouble(cursor.getColumnIndex("longitude")),
                };
                result.add(row);
            }
            cursor.close();
            return result;
        }else{
            Log.i("PEDOLOG_SC", "getHistory...조회하려는 테이블이 비어있습니다.");
            return null;
        }
    }

}
