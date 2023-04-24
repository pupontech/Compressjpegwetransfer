@echo off

rem Get the current directory.
set "current_dir=%CD%"

rem Initialize variables.
set "new_subdir="
set "new_subdir_modified="

:find_newest_subdir
rem Get the list of subdirectories.
for /d %%d in ("%current_dir%\*") do (

  rem Get the last modified date of the subdirectory.
  for %%f in ("%%~d\*") do (
    if /i "%%~xf"==".jpg" (
      for /f "usebackq" %%t in ('echo %%~tf') do set "current_date=%%~t"
      if not defined new_subdir_modified (
        set "new_subdir=%%~d"
        set "new_subdir_modified=!current_date!"
      ) else (
        if "!current_date!" GTR "!new_subdir_modified!" (
          set "new_subdir=%%~d"
          set "new_subdir_modified=!current_date!"
        )
      )
    )
  )

  if not defined new_subdir (
    set "current_dir=%%d"
    goto :find_newest_subdir
  )

)

if not defined new_subdir (
  echo No JPEG files found in "%current_dir%" or its subdirectories.
  pause
  exit /b 1
)

rem Create a zip file of the newest subdirectory.
rem The -mx0 switch specifies the least amount of compression.
rem The -r switch recursively includes all subdirectories.
rem The -bd switch disables the progress bar.
rem The -y switch assumes Yes on all queries.
pushd "%new_subdir%" && (
  7z a -mx0 -r -bd -y "images.zip" "*.jpg"
  popd
)

rem Open the folder containing the zip file in Windows Explorer.
explorer /select,"%new_subdir%\images.zip"

rem Open WeTransfer in the default web browser.
start https://wetransfer.com/

exit /b 0