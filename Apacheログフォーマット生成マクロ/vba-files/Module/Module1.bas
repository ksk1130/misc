Attribute VB_Name = "Module1"
Option Explicit

Sub apache���O�t�H�[�}�b�g����()
    Dim lastIdxNum as Long
    Dim params()
    Dim i as Long
    Dim j as Integer
    Dim tempVal
    Dim logFormat as String
    Dim tempBArr
    Dim tempEArr
    
    lastIdxNum = �w�肵����̍ŉ��s�ԍ����擾("B")

    ' �s�������������̂Ŕz�񒷂�ݒ�
    ' 1�Z��=1�s�Ƃ͌���Ȃ����A��U�s���Őݒ�
    ReDim params(1 To lastIdxNum)

    For i = 3 To lastIdxNum
        tempVal = Range("D" & i).Value

        ' tempVal���󔒂łȂ��ꍇ�͏������{
        if tempVal <> "" then
            ' tempVal�ɉ��s���܂܂�Ă��邩���f
            if InStr(tempVal, vbLf) > 0 then
                '���s�𕪊����Ĕz��Ɋi�[
                tempBArr = Split(tempVal, vbLf)

                ' E��ɒl�������Ă���ꍇ�͉��s�𕪊����Ĕz��Ɋi�[
                if Range("E" & i).Value <> "" then
                    tempEArr = Split(Range("E" & i).Value, vbLf)
                end if

                For j = 0 To UBound(tempBArr)
                    ' E��ɒl�������Ă���ꍇ�͂��̒l���A�����Ă��Ȃ��ꍇ��B��̒l���i�[
                    if Range("E" & i).Value <> "" then
                        params(int(tempBArr(j))) = tempEArr(j)                   
                    else
                        params(int(tempBArr(j))) = Range("B" & i).Value
                    end if
                Next j
            else
                ' tempVal�̉E�̃Z�����󔒂łȂ��ꍇ�͂��̒l���擾
                if Range("E" & i).Value <> "" then
                    params(int(tempVal)) = Range("E" & i).Value
                else
                    params(int(tempVal)) = Range("B" & i).Value
                end if
            end if

        end if
    Next i

    For i = 1 To UBound(params)
        ' params�̒l���󔒂łȂ��ꍇ�̂݃��O�t�H�[�}�b�g�ɒǉ�
        if params(i) <> "" then
            logFormat = logFormat & params(i) & " "
        end if
    Next i

    InputBox "���O�t�H�[�}�b�g", "���O�t�H�[�}�b�g", logFormat

End Sub

Function �w�肵����̍ŉ��s�ԍ����擾(��)
    �w�肵����̍ŉ��s�ԍ����擾 = Cells(Rows.Count, �񖼂��ԍ��ɕϊ�(��)).End(xlUp).Row
End Function

Function �񖼂��ԍ��ɕϊ�(��)
    �񖼂��ԍ��ɕϊ� = Columns(��).Column
End Function
