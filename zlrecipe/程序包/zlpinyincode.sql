create or replace Function Zlpinyincode
(
  v_Instr   In Varchar2,
  n_Mode    In Number := 0,
  n_Initial In Number := 0,
  v_Split   In Varchar2 := Null,
  n_Mutil   In Number := 1,
  n_Outnum  In Number := 10
) Return Varchar2 As
  n_Pos Number(2);
  n_Js  Number(2);
  n_In  Number(2);
-- n_Out     Number(2);
-- v_Mutil   Varchar2(200);
  v_Ascii  Varchar2(2000);
  v_Symbol Varchar2(5);
  v_Spell  Zlpinyin.拼音%Type;
  b_Symbol Number(1);
-- v_Spell_m Zlpinyin.拼音%Type;
  v_Text   Varchar2(2000);
  v_Return Varchar2(2000);

--定义用以处理多音节的可变数组
  Type Ma_Type Is Table Of Varchar2(200);
  Mutilascii Ma_Type := Ma_Type();

--去掉重复的发音内容
  Function Getdistascii(v_Process Varchar2) Return Varchar2 Is
    n_Max  Number(2);
    n_In   Number(2);
    v_Pro  Varchar2(2000);
    v_Sa   Varchar2(1000);
    v_Dist Varchar2(1000);
  Begin
    v_Pro := v_Process;
    v_Sa  := Null;
    While True Loop
  --多音字
      Select Length(v_Process) - Length(Replace(v_Process, ',', '')) + 1 Into n_Max From Dual; --取逗号出现次数
      If n_Max Is Null Then
        n_Max := 1;
      End If;
      v_Dist := Null;
      For n_In In 1 .. n_Max Loop
        If n_In = 1 And n_Max = 1 Then
          v_Sa := v_Process;
        Elsif n_In = 1 And n_Max > 1 Then
          v_Sa := Substr(v_Process, 1, Instr(v_Process, ',', 1, n_In) - 1);
        Elsif n_In < n_Max Then
          v_Sa := Substr(v_Process,
                         Instr(v_Process, ',', 1, n_In - 1) + 1,
                         Instr(v_Process, ',', 1, n_In) - Instr(v_Process, ',', 1, n_In - 1) - 1);
        Elsif n_In = n_Max Then
          v_Sa := Substr(v_Process, Instr(v_Process, ',', 1, n_In - 1) + 1);
        End If;
        If Instr(',' || v_Dist || ',', ',' || v_Sa || ',') = 0 Then
          If v_Dist Is Null Then
            v_Dist := v_Sa;
          Else
            v_Dist := v_Dist || ',' || v_Sa;
          End If;
        End If;
      End Loop;

      If v_Dist Is Null Then
        v_Dist := v_Process;
      End If;
      Return(v_Dist);
    End Loop;
  End;

--递归函数，用来处理多单字
  Function Getmutilascii
  (
    v_Process Varchar2,
    n_Pos     Number
  ) Return Varchar2 Is
    n_Max    Number(2);
    n_Lp     Number(2);
    n_In     Number(2);
    v_Pro    Varchar2(2000);
    v_Ma     Varchar2(2000);
    v_Sa     Varchar2(1000);
    v_Sa_Pro Varchar2(1000);
  Begin
    n_Lp  := n_Pos;
    v_Pro := v_Process;
    v_Sa  := Null;
    v_Ma  := Null;
    While True Loop
  --多音字
      Select Length(Mutilascii(n_Lp)) - Length(Replace(Mutilascii(n_Lp), ',', '')) + 1 Into n_Max From Dual; --取逗号出现次数
      While v_Pro Is Not Null Loop
    --依次取出源串
        If Instr(v_Pro, ',') > 0 Then
          v_Sa_Pro := Substr(v_Pro, 1, Instr(v_Pro, ',') - 1);
          v_Pro    := Substr(v_Pro, Instr(v_Pro, ',') + 1);
        Else
          v_Sa_Pro := v_Pro;
          v_Pro    := Null;
        End If;
    --拼接上当前多音字1,2,3,4
        If n_Max Is Null Then
          n_Max := 1;
        End If;
        For n_In In 1 .. n_Max Loop
          If n_In = 1 And n_Max = 1 Then
            v_Sa := Mutilascii(n_Lp);
          Elsif n_In = 1 And n_Max > 1 Then
            v_Sa := Substr(Mutilascii(n_Lp), 1, Instr(Mutilascii(n_Lp), ',', 1, n_In) - 1);
          Elsif n_In < n_Max Then
            v_Sa := Substr(Mutilascii(n_Lp),
                           Instr(Mutilascii(n_Lp), ',', 1, n_In - 1) + 1,
                           Instr(Mutilascii(n_Lp), ',', 1, n_In) - Instr(Mutilascii(n_Lp), ',', 1, n_In - 1) - 1);
          Elsif n_In = n_Max Then
            v_Sa := Substr(Mutilascii(n_Lp), Instr(Mutilascii(n_Lp), ',', 1, n_In - 1) + 1);
          End If;
          If n_Mode = 1 And (Length(v_Sa) > 1 Or Length(Mutilascii(n_Lp + 1)) > 1) Then
            v_Sa := v_Sa || v_Split || v_Sa_Pro;
          Else
            v_Sa := v_Sa || v_Sa_Pro;
          End If;
          If v_Ma Is Not Null Then
            v_Ma := v_Ma || ',' || v_Sa;
          Else
            v_Ma := v_Sa;
          End If;
        End Loop;
      End Loop;

      If v_Ma Is Null Then
        v_Ma := Mutilascii(n_Lp);
      End If;
      Return(v_Ma);
    End Loop;
  End;
Begin
  If v_Instr Is Null Then
    Return '';
  End If;

  v_Text := v_Instr;
  n_Js   := n_Outnum;
  If n_Js = 0 Or n_Js > Length(v_Text) Then
    n_Js := Length(v_Text);
  End If;
  Mutilascii.Extend(n_Js);

--循环将简码赋值到数组中;
  n_Js := 1;
  While v_Text Is Not Null Loop
    b_Symbol := 0;
    v_Symbol := Substr(v_Text, n_Js, 1);
    Select Asciistr(v_Symbol) Into v_Ascii From Dual;
    If v_Ascii <> v_Symbol And Substr(v_Ascii, 1, 1) = '\' Then
  --不同则说明是汉字
      v_Ascii := To_Number(Substr(v_Ascii, 2), 'XXXX');
      Begin
        Select 拼音 Into v_Spell From Zlpinyin Where 汉字 = v_Ascii;
        b_Symbol := 1;
      Exception
        When Others Then
          v_Spell := v_Symbol;
      End;
      If b_Symbol = 1 Then
    --去掉所有声调(数字)
        v_Spell := Replace(v_Spell, '0', '');
        v_Spell := Replace(v_Spell, '1', '');
        v_Spell := Replace(v_Spell, '2', '');
        v_Spell := Replace(v_Spell, '3', '');
        v_Spell := Replace(v_Spell, '4', '');
        v_Spell := Replace(v_Spell, '5', '');
        v_Spell := Getdistascii(v_Spell);
    --按入参规则处理
        v_Ascii := Null;
        If n_Mode = 0 Then
      --取首字母
          While True Loop
            If v_Ascii Is Null Then
              v_Ascii := Substr(v_Spell, 1, 1);
            Else
              v_Ascii := v_Ascii || ',' || Substr(v_Spell, 1, 1);
            End If;
            n_In := Instr(v_Spell, ',', 1);
            If n_In > 0 Then
              v_Spell := Substr(v_Spell, n_In + 1);
            Else
              Exit;
            End If;
          End Loop;
          v_Ascii := Upper(v_Ascii);
        Else
          v_Ascii := Lower(v_Spell);
          If n_Initial = 0 Then
        --全部大写
            v_Ascii := Upper(v_Ascii);
          Else
        --首字母大写
            n_Pos   := 2;
            v_Ascii := Upper(Substr(v_Ascii, 1, 1)) || Substr(v_Ascii, 2);
            While n_Pos <= Length(v_Ascii) Loop
              If Substr(v_Ascii, n_Pos - 1, 1) = ',' Then
                v_Ascii := Substr(v_Ascii, 1, n_Pos - 1) || Upper(Substr(v_Ascii, n_Pos, 1)) ||
                           Substr(v_Ascii, n_Pos + 1);
              End If;
              n_Pos := n_Pos + 1;
            End Loop;
          End If;
        End If;
        Mutilascii(n_Js) := v_Ascii;
      Else
        Mutilascii(n_Js) := v_Symbol;
      End If;
    Else
      Mutilascii(n_Js) := v_Ascii;
    End If;
    n_Js := n_Js + 1;
    If n_Js > Mutilascii.Count Then
      Exit;
    End If;
  End Loop;

  n_In := Mutilascii.Count;
  While n_In > 0 Loop
    v_Return := Getmutilascii(v_Return, n_In);
    n_In     := n_In - 1;
  End Loop;

  If n_Mutil = 0 Then
    Return Substr(v_Return || ',', 1, Instr(v_Return || ',', ',', 1) - 1);
  Else
    Return v_Return;
  End If;
Exception
  When Others Then
    Return '';
End Zlpinyincode;
