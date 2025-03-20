package jp.euks.fastexceltest;

import java.io.FileInputStream;
import java.io.IOException;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

import org.dhatim.fastexcel.reader.Cell;
import org.dhatim.fastexcel.reader.ReadableWorkbook;
import org.dhatim.fastexcel.reader.Row;

import lombok.val;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

public class FastExcelTest {
    private String dbPath;
    private String excelPath;

    private static final Logger LOGGER = LogManager.getLogger(FastExcelTest.class);

    /**
     * FastExcelTestクラスのコンストラクタ。
     * 
     * @param dbPath    データベースのパス
     * @param excelPath Excelファイルのパス
     */
    public FastExcelTest(String dbPath, String excelPath) {
        this.dbPath = dbPath;
        this.excelPath = excelPath;
        LOGGER.info("dbPath:%s excelPath:%s".formatted(dbPath, excelPath));
    }

    public static void main(String[] args) {
        val dbPath = args[0];
        val excelPath = args[1];

        val feText = new FastExcelTest(dbPath, excelPath);

        try {
            // FastExcelでExcelファイルを読み込み、ArrayListを返す
            val results = feText.loadExcel();

            try (val connection = DriverManager.getConnection("jdbc:h2:" + dbPath);
                    val statement = connection.createStatement()) {

                // H2DBにExcelに対応するテーブルを作成する
                createTable(statement);

                // テーブルにArrayListの内容をInsertする
                insertData(results, statement);

            } catch (SQLException e) {
                e.printStackTrace();
            }
        } catch (IOException e) {
            e.printStackTrace();
        }

    }

    /**
     * 指定された結果リストを使用してデータベースにデータを挿入します。
     *
     * @param results   データを含むリスト。各要素は文字列配列であり、データベースに挿入される行を表します。
     * @param statement データベースへのSQL文を実行するためのStatementオブジェクト。
     * @throws SQLException データベースアクセスエラーが発生した場合、またはSQL文が正しくない場合にスローされます。
     */
    private static void insertData(final List<String[]> results, Statement statement) throws SQLException {
        // データ挿入のSQL文を生成
        val insertSQLPrefix = "INSERT INTO exceldata VALUES (";

        // データ挿入の準備
        for (int i = 1; i < results.size(); i++) {
            val row = results.get(i);
            val rowString = String.join("','", row);
            val insertSQL = insertSQLPrefix + "'" + rowString + "')";
            LOGGER.debug("sql:" + insertSQL);

            statement.execute(insertSQL);
        }
    }

    /**
     * 指定されたステートメントを使用して、データベースに `exceldata` テーブルを作成します。
     * テーブルが既に存在する場合は、最初に削除されます。
     *
     * @param statement SQLステートメントを実行するための `Statement` オブジェクト
     * @throws SQLException SQL操作中にエラーが発生した場合
     */
    private static void createTable(Statement statement) throws SQLException {
        val dropTableSQL = "drop table if exists exceldata";
        statement.executeUpdate(dropTableSQL);

        // テーブル作成のSQL文を生成
        val createTableSQL = """
                create table exceldata(
                entity_type varchar(4096)
                ,entity_name_phonetic varchar(4096)
                ,entity_name varchar(4096)
                ,entity_main_office_postal_code varchar(4096)
                ,entity_main_office_prefecture varchar(4096)
                ,entity_main_office_city varchar(4096)
                ,entity_main_office_town_address varchar(4096)
                ,entity_main_office_building_details varchar(4096)
                ,entity_contact_phone_number varchar(4096)
                ,entity_contact_other varchar(4096)
                ,entity_representative_name varchar(4096)
                ,entity_representative_position varchar(4096)
                ,entity_establishment_date varchar(4096)
                ,entity_educational_facility_details varchar(4096)
                ,main_or_branch_existence varchar(4096)
                ,branch_facility_1_name varchar(4096)
                ,branch_facility_2_name varchar(4096)
                ,branch_facility_3_name varchar(4096)
                ,branch_facility_4_name varchar(4096)
                ,branch_facility_5_name varchar(4096)
                ,branch_facility_6_name varchar(4096)
                ,branch_facility_7_name varchar(4096)
                ,branch_facility_8_name varchar(4096)
                ,branch_facility_9_name varchar(4096)
                ,facility_type varchar(4096)
                ,facility_name_phonetic varchar(4096)
                ,facility_name varchar(4096)
                ,office_number varchar(4096)
                ,postal_code varchar(4096)
                ,facility_location_prefecture varchar(4096)
                ,facility_location_city varchar(4096)
                ,facility_location_town_address varchar(4096)
                ,facility_location_building_details varchar(4096)
                ,facility_contact_phone_number varchar(4096)
                ,facility_contact_other varchar(4096)
                ,facility_operator varchar(4096)
                ,facility_manager_name varchar(4096)
                ,facility_manager_position varchar(4096)
                ,business_authorization_date varchar(4096)
                ,business_start_date varchar(4096)
                ,business_confirmation_date varchar(4096)
                ,business_status varchar(4096)
                ,partner_facility_01_name varchar(4096)
                ,partner_facility_01_details varchar(4096)
                ,partner_facility_01_other_details varchar(4096)
                ,partner_facility_02_name varchar(4096)
                ,partner_facility_02_details varchar(4096)
                ,partner_facility_02_other_details varchar(4096)
                ,partner_facility_03_name varchar(4096)
                ,partner_facility_03_details varchar(4096)
                ,partner_facility_03_other_details varchar(4096)
                ,partner_facility_04_name varchar(4096)
                ,partner_facility_04_details varchar(4096)
                ,partner_facility_04_other_details varchar(4096)
                ,partner_facility_05_name varchar(4096)
                ,partner_facility_05_details varchar(4096)
                ,partner_facility_05_other_details varchar(4096)
                ,partner_facility_06_name varchar(4096)
                ,partner_facility_06_details varchar(4096)
                ,partner_facility_06_other_details varchar(4096)
                ,partner_facility_07_name varchar(4096)
                ,partner_facility_07_details varchar(4096)
                ,partner_facility_07_other_details varchar(4096)
                ,partner_facility_08_name varchar(4096)
                ,partner_facility_08_details varchar(4096)
                ,partner_facility_08_other_details varchar(4096)
                ,partner_facility_09_name varchar(4096)
                ,partner_facility_09_details varchar(4096)
                ,partner_facility_09_other_details varchar(4096)
                ,partner_facility_10_name varchar(4096)
                ,partner_facility_10_details varchar(4096)
                ,partner_facility_10_other_details varchar(4096)
                ,childcare_teacher_full_time_count varchar(4096)
                ,childcare_teacher_part_time_count varchar(4096)
                ,childcare_teacher_work_hours varchar(4096)
                ,childcare_teacher_avg_years_experience_full_time varchar(4096)
                ,childcare_teacher_avg_years_experience_part_time varchar(4096)
                ,teacher_or_childcare_worker_full_time_count varchar(4096)
                ,teacher_or_childcare_worker_part_time_count varchar(4096)
                ,teacher_or_childcare_worker_work_hours varchar(4096)
                ,teacher_or_childcare_worker_avg_years_experience_full_time varchar(4096)
                ,teacher_or_childcare_worker_avg_years_experience_part_time varchar(4096)
                ,childcare_worker_full_time_count varchar(4096)
                ,childcare_worker_part_time_count varchar(4096)
                ,childcare_worker_work_hours varchar(4096)
                ,childcare_worker_avg_years_experience_full_time varchar(4096)
                ,childcare_worker_avg_years_experience_part_time varchar(4096)
                ,childcare_staff_full_time_count varchar(4096)
                ,childcare_staff_part_time_count varchar(4096)
                ,childcare_staff_work_hours varchar(4096)
                ,childcare_staff_avg_years_experience_full_time varchar(4096)
                ,childcare_staff_avg_years_experience_part_time varchar(4096)
                ,teacher_full_time_count varchar(4096)
                ,teacher_part_time_count varchar(4096)
                ,teacher_work_hours varchar(4096)
                ,teacher_avg_years_experience_full_time varchar(4096)
                ,teacher_avg_years_experience_part_time varchar(4096)
                ,home_based_childcare_worker_full_time_count varchar(4096)
                ,home_based_childcare_worker_part_time_count varchar(4096)
                ,home_based_childcare_worker_work_hours varchar(4096)
                ,home_based_childcare_worker_avg_years_experience_full_time varchar(4096)
                ,home_based_childcare_worker_avg_years_experience_part_time varchar(4096)
                ,nurse_full_time_count varchar(4096)
                ,nurse_part_time_count varchar(4096)
                ,nurse_work_hours varchar(4096)
                ,nurse_avg_years_experience_full_time varchar(4096)
                ,nurse_avg_years_experience_part_time varchar(4096)
                ,total_full_time_staff_count varchar(4096)
                ,total_part_time_staff_count varchar(4096)
                ,children_per_staff varchar(4096)
                ,held_licenses_and_qualifications varchar(4096)
                ,held_licenses_and_qualifications_other varchar(4096)
                ,opening_days_weekdays varchar(4096)
                ,opening_days_weekday_opening_time varchar(4096)
                ,opening_days_weekday_closing_time varchar(4096)
                ,opening_days_saturday_opening_time varchar(4096)
                ,opening_days_saturday_closing_time varchar(4096)
                ,opening_days_holiday_opening_time varchar(4096)
                ,opening_days_holiday_closing_time varchar(4096)
                ,extended_care_morning_opening_time varchar(4096)
                ,extended_care_morning_closing_time varchar(4096)
                ,extended_care_afternoon_opening_time varchar(4096)
                ,extended_care_afternoon_closing_time varchar(4096)
                ,childcare_hours_weekday_open varchar(4096)
                ,childcare_hours_weekday_close varchar(4096)
                ,childcare_hours_saturday_open varchar(4096)
                ,childcare_hours_saturday_close varchar(4096)
                ,childcare_hours_holiday_open varchar(4096)
                ,childcare_hours_holiday_close varchar(4096)
                ,age_0_capacity varchar(4096)
                ,age_0_users varchar(4096)
                ,age_0_class_count varchar(4096)
                ,age_1_capacity varchar(4096)
                ,age_1_users varchar(4096)
                ,age_1_class_count varchar(4096)
                ,age_2_capacity varchar(4096)
                ,age_2_users varchar(4096)
                ,age_2_class_count varchar(4096)
                ,age_3_capacity varchar(4096)
                ,age_3_users varchar(4096)
                ,age_3_class_count varchar(4096)
                ,age_4_capacity varchar(4096)
                ,age_4_users varchar(4096)
                ,age_4_class_count varchar(4096)
                ,age_5_capacity varchar(4096)
                ,age_5_users varchar(4096)
                ,age_5_class_count varchar(4096)
                ,total_capacity varchar(4096)
                ,total_users varchar(4096)
                ,total_class_count varchar(4096)
                ,operating_method varchar(4096)
                ,educational_and_care_contents varchar(4096)
                ,meal_provision_status varchar(4096)
                ,meal_provision_days varchar(4096)
                ,system_for_children_with_disabilities varchar(4096)
                ,temporary_childcare_implementation varchar(4096)
                ,sick_childcare_implementation varchar(4096)
                ,room_area varchar(4096)
                ,building_area varchar(4096)
                ,playground_area varchar(4096)
                ,usage_procedures varchar(4096)
                ,selection_criteria varchar(4096)
                ,other_usages varchar(4096)
                ,complaint_contact_status varchar(4096)
                ,response_to_accidents varchar(4096)
                ,service_features varchar(4096)
                ,actual_cost_collected varchar(4096)
                ,actual_cost_reason varchar(4096)
                ,actual_cost_amount varchar(4096)
                ,additional_cost_collected varchar(4096)
                ,additional_cost_reason varchar(4096)
                ,additional_cost_amount varchar(4096)
                ,initial_service_explanation varchar(4096)
                ,user_agreement varchar(4096)
                ,explanation_of_user_burden varchar(4096)
                ,efforts_for_complaint_handling varchar(4096)
                ,accident_prevention_and_response varchar(4096)
                ,personal_information_handling varchar(4096)
                ,third_party_evaluation_status varchar(4096)
                ,third_party_evaluation_results varchar(4096)
                ,free_service_facility_availability varchar(4096)
                ,prefectural_governor_notes varchar(4096)
                )
                """;

        // テーブル作成の実行
        statement.executeUpdate(createTableSQL);
    }

    /**
     * Excelファイルを読み込み、各行のデータをリストとして返します。
     *
     * @return 各行のデータを格納したリスト
     * @throws IOException 入出力エラーが発生した場合
     */
    private List<String[]> loadExcel() throws IOException {
        val results = new ArrayList<String[]>();

        try (val is = new FileInputStream(this.excelPath);
                val wb = new ReadableWorkbook(is)) {
            val sheet = wb.getFirstSheet();

            // 行のリスト
            val rows = sheet.read();

            val header = rows.get(0);
            val cells = transCellstoList(header);
            System.out.println(cells.length);
            results.add(cells);

            for (var i = 1; i < rows.size(); i++) {
                val tmpCells = transCellstoList(rows.get(i), cells.length);
                results.add(tmpCells);
            }

            System.out.println("rows:" + rows.size());
        }

        return results;
    }

    /**
     * 指定された行のセルを文字列の配列に変換します。
     * 
     * @param row    変換対象の行
     * @param length 変換後の配列の長さ
     * @return セルの内容を文字列として格納した配列。セルが存在しない場合は空文字列が格納されます。
     */
    private String[] transCellstoList(Row row, int length) {
        val cellCnt = row.getCellCount();
        LOGGER.info("cellCnt:" + cellCnt);

        val cells = row.getCells(0, cellCnt);
        if (cellCnt < length) {
            val empList = new ArrayList<Cell>();

            for (var i = 0; i < (length - cellCnt); i++) {
                empList.add(null);
            }
            LOGGER.debug("empList:" + empList.size());
            cells.addAll(empList);
        }

        val cellsArr = new String[cells.size()];

        for (var i = 0; i < cells.size(); i++) {
            val cell = cells.get(i);
            if (cell != null) {
                cellsArr[i] = cell.getText();
            } else {
                cellsArr[i] = "";
            }
        }

        return cellsArr;
    }

    /**
     * 指定されたヘッダー行のセルを文字列のリストに変換します。
     *
     * @param header 変換するヘッダーセルを含む行
     * @return ヘッダー行の各セルのテキストを表す文字列の配列
     */
    private String[] transCellstoList(Row row) {
        return row.stream()
                .map(cell -> cell == null ? "" : cell.getText())
                .toArray(String[]::new);
    }

}
