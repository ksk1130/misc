package postgres_varchartest;

import java.io.IOException;
import java.io.UnsupportedEncodingException;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.Properties;

public class Main {
	private static final String PROP_FILE_PATH = "conf/project_settings.properties";

	private static Properties properties;

	private static String[] values = { "1234567890", "一二三", "一𪘂𪗱", "一二三四", "一二三四五六七八九十", "𠀋𡈽𡌛𡑮𡢽𠮟𡚴𡸴𣇄𣗄",
			"12345678901", "一二三四五六七八九十一", "𠀋𡈽𡌛𡑮𡢽𠮟𡚴𡸴𣇄𣗄𣜿" };

	public static void main(String[] args) {
		properties = new Properties();
		try {
			properties.load(Files.newBufferedReader(Paths.get(PROP_FILE_PATH), StandardCharsets.UTF_8));
		} catch (IOException e) {
			// ファイル読み込みに失敗
			System.out.println(String.format("ファイルの読み込みに失敗しました。ファイル名:%s", PROP_FILE_PATH));
		}

		try {
			for (String value : values) {
				System.out.printf("Value:%s,\tLength of value:%d,\tLength of bytes:%d\r\n", value, value.length(),
						value.getBytes("UTF-8").length);
			}
		} catch (UnsupportedEncodingException e) {
			e.printStackTrace();
		}

		execDBOperation();
	}

	private static void execDBOperation() {
		Connection conn = null;
		Statement stmt = null;
		ResultSet rset = null;
		PreparedStatement pstmt = null;

		// 接続文字列をPropertieファイルから取得
		String url = properties.getProperty("url");
		String user = properties.getProperty("user");
		String password = properties.getProperty("password");

		try {
			// PostgreSQLへ接続
			conn = DriverManager.getConnection(url, user, password);
			// 自動コミットはなし
			conn.setAutoCommit(false);
			stmt = conn.createStatement();

			// テーブル削除
			final String sqlForDropTable = "drop table varchar_test";
			final int retValofDropTable = stmt.executeUpdate(sqlForDropTable);
			// DDL文もコミット要につきコミット
			conn.commit();

			// テーブル作成
			final String sqlForCreateTable = "create table varchar_test(id int, varchar_col varchar(10));";
			final int retValOfCreateTable = stmt.executeUpdate(sqlForCreateTable);
			// DDL文もコミット要につきコミット
			conn.commit();

			// データ投入
			for(int i =0 ;i < values.length;i++) {
				System.out.println(values[i]);

				final String sql = "insert into varchar_test(id, varchar_col) values(?, ?);";
				pstmt = conn.prepareStatement(sql);
				pstmt.setInt(1, i+1);
				pstmt.setString(2, values[i]);
				int retExecute = pstmt.executeUpdate();

				// 挿入成功したらコミット
				if (retExecute == 1) {
					conn.commit();
				}
			}

		} catch (SQLException e) {
			e.printStackTrace();

			// 何らかのエラーがあったらロールバック
			if (conn != null) {
				try {
					conn.rollback();
				} catch (SQLException e1) {
					// TODO Auto-generated catch block
					e1.printStackTrace();
				}
			}
		} finally {
			try {
				// 処理終了前にDB格納内容を表示
				if (conn != null && stmt != null) {
					final String sql = "SELECT varchar_col from varchar_test order by id asc";
					rset = stmt.executeQuery(sql);

					while (rset.next()) {
						String col = rset.getString(1);
						System.out.println(col);
					}
				}

				if (conn != null) {
					conn.close();
				}
				if (stmt != null) {
					stmt.close();
				}
				if (pstmt != null) {
					pstmt.close();
				}
				if (rset != null) {
					rset.close();
				}

			} catch (SQLException e) {
				e.printStackTrace();
			}

		}
	}
}
