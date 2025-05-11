package jp.euks.methodfinder;

import java.io.File;
import java.io.FileInputStream;
import java.util.ArrayList;
import java.util.List;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import com.github.javaparser.JavaParser;
import com.github.javaparser.ast.body.MethodDeclaration;

import lombok.val;

public class MethodFinder {
    private static final Logger LOGGER = LogManager.getLogger(MethodFinder.class);
    private static List<String> fileNames = new ArrayList<>();

    public MethodFinder(String basePath) {
        LOGGER.info("basePath: {}", basePath);

        // basePath配下のディレクトリから.javaファイルを再帰的に取得し、fileNamesに格納
        LOGGER.info("ファイル名一覧取得");
        findJavaFiles(basePath);
        LOGGER.info("ファイル名一覧取得完了:" + fileNames.size() + "件");
    }

    /**
     * basePath配下のディレクトリを再帰的に探索し、.javaファイルをfileNamesに追加
     * 
     * @param basePath 探索するディレクトリのパス
     */
    private void findJavaFiles(String basePath) {
        // basePath配下のディレクトリを再帰的に探索し、.javaファイルをfileNamesに追加
        LOGGER.debug("探索中: {}", basePath);
        val file = new File(basePath);
        if (file.isDirectory()) {
            if (file.listFiles() == null) {
                LOGGER.debug("ファイルが存在しません:" + basePath);
                return;
            }
            for (val f : file.listFiles()) {
                if (f.isDirectory()) {
                    findJavaFiles(f.getAbsolutePath());
                } else if (f.getName().endsWith(".java")) {
                    fileNames.add(f.getAbsolutePath());
                }
            }
        }
    }

    /**
     * fileNamesから各ファイルを読み込み、メソッド内にsearchWordsを含むメソッド名をJavaParserで取得
     * 
     * @param searchWords 検索する単語のリスト
     */
    public void findMethodNameByWord(ArrayList<String> searchWords) {
        // fileNamesから各ファイルを読み込み、メソッド内にsearchWordsを含むメソッド名をJavaParserで取得
        for (val fileName : fileNames) {
            LOGGER.debug("ファイル名: {}", fileName);
            try (val inputStream = new FileInputStream(fileName)) {
                val compilationUnit = new JavaParser().parse(inputStream);

                compilationUnit.ifSuccessful(cu -> {
                    cu.findAll(MethodDeclaration.class).forEach(method -> {
                        for (val searchWord : searchWords) {
                            if (method.getBody().isPresent()
                                    && method.getBody().get().toString().contains(searchWord)) {
                                LOGGER.info("ファイル名: {}, メソッド名: {}", fileName, method.getNameAsString());
                            }
                        }
                    });
                });
            } catch (Exception e) {
                LOGGER.error("ファイル読み込みエラー: {}", e.getMessage());
            }
        }
    }

    public static void main(String[] args) {
        // コマンドライン引数からbasePathを取得
        if (args.length < 2) {
            LOGGER.info("引数の数：" + args.length);
            LOGGER.error("basePathとsearchWordsを指定してください");
            return;
        }
        val basePath = args[0];

        // args[1]以降の引数を取得し、リストに格納
        val searchWords = new ArrayList<String>();
        for (int i = 1; i < args.length; i++) {
            searchWords.add(args[i]);
        }

        // MethodFinderのインスタンスを生成
        val methodFinder = new MethodFinder(basePath);

        // メソッド名を検索
        methodFinder.findMethodNameByWord(searchWords);
    }
}
