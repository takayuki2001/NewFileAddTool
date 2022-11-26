@echo off

rem 遅延環境変数有効化
setlocal enabledelayedexpansion

echo admin check.

rem 管理者権限をチェック
openfiles > nul 2>&1
if %errorlevel% equ 1 (
    rem 管理者権限がない場合は管理者権限で再実行
    echo this pront is not running admin mode.
	PowerShell.exe -Command Start-Process \"%~f0\" -Verb runas
) else (
    rem 管理者権限の場合はこっち
    echo this pront is running admin mode.

    :exinput
    rem 拡張子を入力してもらう
    echo enter the extension to add to the New File menu.
    set /p extensionStr=">"

    rem .から始まらないものは拡張子ならず
    if "!extensionStr:~0,1!"=="." (
        rem 拡張子だったらこっち

        rem まず拡張子のKeyがあるかを確認無ければ作る
        reg query "HKEY_CLASSES_ROOT\!extensionStr!" > nul 2>&1
        if !errorlevel! equ 1 (
            echo HKEY_CLASSES_ROOT\!extensionStr! is not found. to create.
            reg add "HKEY_CLASSES_ROOT\!extensionStr!"
        )

        rem この時点では絶対拡張子のKeyはあるはずなので無ければエラー
        reg query "HKEY_CLASSES_ROOT\!extensionStr!" > nul 2>&1
        if !errorlevel! equ 1 (
            echo error1
            pause
            exit
        ) else (
            echo HKEY_CLASSES_ROOT\!extensionStr! is found.
        )

        rem 拡張子のKeyの中にShellNewKeyがあるかを確認 無ければ作る あるならば既存値を上書きしてしまうのでエラー
        reg query "HKEY_CLASSES_ROOT\!extensionStr!\ShellNew" > nul 2>&1
        if !errorlevel! equ 1 (
            echo HKEY_CLASSES_ROOT\!extensionStr!\ShellNew is not found. to create.
            reg add "HKEY_CLASSES_ROOT\!extensionStr!\ShellNew"
        ) else (
            echo error2
            pause
            exit
        )

        rem この時点で拡張子/ShellNew Keyは絶対あるはずなので無ければエラー
        reg query "HKEY_CLASSES_ROOT\!extensionStr!\ShellNew" > nul 2>&1
        if !extensionStr! equ 1 (
            echo error3
            pause
            exit
        ) else (
            echo HKEY_CLASSES_ROOT\!extensionStr!\ShellNew is found.
        )

        rem 拡張子/ShellNewにNullFileを作る
        reg add "HKEY_CLASSES_ROOT\!extensionStr!\ShellNew" /v "NullFile" /t REG_SZ

        rem 拡張子 Keyのデフォルト値を取得
        FOR /F "TOKENS=1,2,*" %%I IN ('REG QUERY "HKEY_CLASSES_ROOT\!extensionStr!" /ve ') DO SET GET_VALUE=%%K
        echo !GET_VALUE!

        rem もしデフォルト値が無ければFileTypeを聞く
        if "!GET_VALUE!"=="(value not set)" (
            echo File type is not set.
            
            echo enter the file type.
            set /p filetypeStr=">"

            rem ファイルタイプKeyがあるか確認　無ければ作成しデフォルト値はファイルタイプ名
            reg query "HKEY_CLASSES_ROOT\!filetypeStr!" > nul 2>&1
            if !errorlevel! equ 1 (
                echo HKEY_CLASSES_ROOT\!filetypeStr! is not found. to create.
                reg add "HKEY_CLASSES_ROOT\!filetypeStr!" /ve /d "!filetypeStr!"
            ) else (
                echo HKEY_CLASSES_ROOT\!filetypeStr! is found.
            )

            rem この時点で絶対にファイルタイプKeyがあるのでそれを拡張子のデフォルト値に設定
            reg add "HKEY_CLASSES_ROOT\!extensionStr!" /f /ve /d !filetypeStr!
        )

        rem おわり
        echo Complete!
        pause
        
    ) else (
        rem .で始まらない！？なんてこった！！打ち直しさせよ
        echo extension must start with "."
        goto exinput
    )
)

exit

