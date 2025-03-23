package jp.euks.javastress;

import java.util.concurrent.Executors;
import java.util.concurrent.TimeUnit;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import lombok.val;

/**
 * JavaStressクラスは、指定された時間とスレッド数に基づいて素数計算タスクを実行するプログラムです。
 * 
 * <p>
 * このクラスは以下の機能を提供します:
 * <ul>
 *   <li>コマンドライン引数で実行時間（秒単位）とスレッド数を指定可能。</li>
 *   <li>指定された時間が経過するとタスクを自動的に終了。</li>
 *   <li>スレッド数がCPUコア数を超えないように制限。</li>
 *   <li>素数計算タスクを並列で実行し、計算された素数をログに出力。</li>
 * </ul>
 * </p>
 * 
 * <p>
 * 注意事項:
 * <ul>
 *   <li>実行時間は最大600秒（10分）未満に制限されています。</li>
 *   <li>スレッド数は利用可能なCPUコア数以下に制限されています。</li>
 *   <li>素数計算タスクは計算負荷が高いため、実行環境に応じた適切な設定が必要です。</li>
 * </ul>
 * </p>
 * 
 * <p>
 * 使用例:
 * <pre>
 * java JavaStress 30 4
 * </pre>
 * 上記の例では、30秒間、4つのスレッドで素数計算タスクを実行します。
 * </p>
 */
public class JavaStress {
    private static final Logger LOGGER = LogManager.getLogger(JavaStress.class);

    public static void main(String[] args) {
        // デフォルトの実行時間は10秒
        var duration = 10;

        // デフォルトのスレッド数は1
        var threadCount = 1;

        // 引数が指定されていたら、秒として設定
        if (args.length > 0) {
            try {
                duration = Integer.parseInt(args[0]);

                // 2つ目の引数が指定されていたら、スレッド数として設定
                if (args.length == 2) {
                    threadCount = Integer.parseInt(args[1]);
                }
            } catch (NumberFormatException e) {
                System.err.println("引数は整数で指定してください");
                return;
            }
        }

        LOGGER.info("処理時間(秒):" + duration);

        // 10分以上を指定された場合はエラー
        if (duration > 600) {
            System.err.println("秒数には600秒(10分)未満を指定してください");
            return;
        }

        // スレッド数がCPUコア数を超える場合はエラー
        if (threadCount > Runtime.getRuntime().availableProcessors()) {
            System.err.println("スレッド数は" + Runtime.getRuntime().availableProcessors() + "以下にしてください");
            return;
        }

        LOGGER.info("処理開始");

        // 処理を開始
        for (var i = 0; i < threadCount; i++) {
            startProcess(duration);
        }
    }

    /**
     * 指定された期間、素数計算タスクを実行し、その後タスクを終了します。
     * 
     * <p>
     * このメソッドは2つのスレッドを使用します。一つは素数を計算しログに出力するタスク、
     * もう一つは指定された期間が経過した後に全てのタスクを終了するためのタスクです。
     * </p>
     * 
     * @param duration 実行時間（秒単位）。この時間が経過するとタスクが終了します。
     */
    private static void startProcess(int duration) {
        // 素数計算タスクと、終了タスクを実行するため2つのスレッドを生成
        val executor = Executors.newScheduledThreadPool(2);

        executor.submit(() -> {
            try {
                for (var i = 0; i < Integer.MAX_VALUE; i++) {
                    if (Thread.currentThread().isInterrupted()) {
                        throw new InterruptedException();
                    }
                    if (isPrime(i)) {
                        LOGGER.info("素数: " + i);
                    }
                }
            } catch (InterruptedException e) {
                LOGGER.info("スレッドに割り込みが発生しました");
            }
        });

        executor.schedule(() -> {
            executor.shutdownNow();
            LOGGER.info("実行終了");
        }, duration, TimeUnit.SECONDS);
    }

    /**
     * 指定された整数が素数であるかどうかを判定します。
     *
     * @param a 判定対象の整数
     * @return 整数が素数である場合は {@code true}、そうでない場合は {@code false}
     * 
     *         <p>
     *         このメソッドは以下の条件に基づいて素数を判定します:
     *         <ul>
     *         <li>1以下の数値や偶数（2を除く）は素数ではありません。</li>
     *         <li>2は素数です。</li>
     *         <li>3以上の奇数については、平方根までの奇数で割り切れるかどうかを確認します。</li>
     *         </ul>
     */
    private static boolean isPrime(int a) {
        if (a <= 1) {
            return false;
        }
        if (a == 2) {
            return true;
        }
        if (a % 2 == 0) {
            return false;
        }
        for (var i = 3; i <= Math.sqrt(a); i += 2) {
            if (a % i == 0) {
                return false;
            }
        }
        return true;
    }

}
