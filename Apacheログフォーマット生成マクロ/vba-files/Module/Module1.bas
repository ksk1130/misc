Attribute VB_Name = "Module1"
Option Explicit

Sub apacheログフォーマット生成()
    Dim lastIdxNum as Long
    Dim params()
    Dim i as Long
    Dim j as Integer
    Dim tempVal
    Dim logFormat as String
    Dim tempBArr
    Dim tempEArr
    
    lastIdxNum = 指定した列の最下行番号を取得("B")

    ' 行数が判明したので配列長を設定
    ' 1セル=1行とは限らないが、一旦行数で設定
    ReDim params(1 To lastIdxNum)

    For i = 3 To lastIdxNum
        tempVal = Range("D" & i).Value

        ' tempValが空白でない場合は処理実施
        if tempVal <> "" then
            ' tempValに改行が含まれているか判断
            if InStr(tempVal, vbLf) > 0 then
                '改行を分割して配列に格納
                tempBArr = Split(tempVal, vbLf)

                ' E列に値が入っている場合は改行を分割して配列に格納
                if Range("E" & i).Value <> "" then
                    tempEArr = Split(Range("E" & i).Value, vbLf)
                end if

                For j = 0 To UBound(tempBArr)
                    ' E列に値が入っている場合はその値を、入っていない場合はB列の値を格納
                    if Range("E" & i).Value <> "" then
                        params(int(tempBArr(j))) = tempEArr(j)                   
                    else
                        params(int(tempBArr(j))) = Range("B" & i).Value
                    end if
                Next j
            else
                ' tempValの右のセルが空白でない場合はその値を取得
                if Range("E" & i).Value <> "" then
                    params(int(tempVal)) = Range("E" & i).Value
                else
                    params(int(tempVal)) = Range("B" & i).Value
                end if
            end if

        end if
    Next i

    For i = 1 To UBound(params)
        ' paramsの値が空白でない場合のみログフォーマットに追加
        if params(i) <> "" then
            logFormat = logFormat & params(i) & " "
        end if
    Next i

    InputBox "ログフォーマット", "ログフォーマット", logFormat

End Sub

Function 指定した列の最下行番号を取得(列名)
    指定した列の最下行番号を取得 = Cells(Rows.Count, 列名を列番号に変換(列名)).End(xlUp).Row
End Function

Function 列名を列番号に変換(列名)
    列名を列番号に変換 = Columns(列名).Column
End Function
