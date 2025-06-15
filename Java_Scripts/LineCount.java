import java.nio.charset.Charset;
import java.nio.charset.MalformedInputException;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.io.IOException;
import java.io.UncheckedIOException;

/**
 * ファイルの行数をカウントするプログラム
 * このプログラムは、指定されたファイルを複数のエンコーディングで読み込み、
 * 行数をカウントします。
 * 対応するエンコーディングは以下の通りです:
 * - UTF-8
 * - Shift_JIS
 * - EUC-JP
 * - ISO-2022-JP
 * * コマンドライン引数でファイルパスを指定してください。
 * Java 11以降では、コンパイルをせずに直接実行できます。
 * 例:
 * java LineCount sample.txt
 */
public class LineCount {
    private static String[] ENCODINGS = new String[] { "UTF-8", "Shift_JIS", "EUC-JP", "ISO-2022-JP" };

    public static void main(String[] args) {
        // コマンドライン引数が指定されていなければエラーを表示して終了
        if (args.length != 1) {
            System.out.println("Usage: java LineCount <file-path>");
            return;
        }

        var filePath = args[0];
        var success = false;

        // 指定されたエンコーディングでファイルを読み込み、行数をカウント
        for (var encoding : ENCODINGS) {
            try (var lines = Files.lines(Paths.get(filePath), Charset.forName(encoding))) {
                long lineCount = lines.count();
                System.out.println("Encoding: " + encoding);
                System.out.println("Number of lines in the file: " + lineCount);
                success = true;
                break;
            } catch (UncheckedIOException e) {
                // 例外が発生した場合は次のエンコーディングを試す
                System.err.println("UncheckedIOException: " + encoding + " で読み込み失敗");
            } catch (IOException e) {
                System.err.println("IOException: " + encoding + " で読み込み失敗");
            }
        }

        if (!success) {
            System.err.println("どのエンコーディングでもファイルを読み込めませんでした。");
        }
    }
}