REM # ROBOT_DE_COPIA.BAT
REM # copia entre dos unidades utilizando robocopy
REM # Es capaz de hacer la copia identificando las unidades por el label del disco sin 
REM # dependencia de que el usuario tenga que estar pendiente de la letra de la unidad. 
REM
REM # Autor: Carlos Romeo VL
REM #        cromeovl@gmail.com

@echo off
setlocal
setlocal EnableDelayedExpansion

REM *** CONFIGURACIÓN *** Las letras de unidad se quitan despues. Aqui estan para mejorar lectura
set "etiqueta_origen=usb_primero"
set "etiqueta_destino=usb_segundo"
set "directorio_origen=X:\datos\de\origen"
set "directorio_destino=Y:\destino\copia\"
set "dir_log=X:\datos\Logs"

REM *** Otras variables ***
rem set "nombre_copia=!directorio_destino:~3!
set "fecha_hora=!date:~6,4!!date:~3,2!!date:~0,2!.!time:~0,2!!time:~3,2!!time:~6,2!"
set "unidad_origen="
set "unidad_destino="

echo.
echo Buscando discos externos...

REM Encontrar la letra de la unidad de origen por su etiqueta 
for /f "tokens=1,2 delims=:" %%a in ('wmic logicaldisk get caption^,volumename') do (
	set "uno=%%a"
	set "dos=%%b"
	set "tres=%%c" 
	
	set unidad=!uno!
	set etiqueta=!dos!
	
	echo "!etiqueta!" | findstr /C:"!etiqueta_origen!" > nul
    if "!errorlevel!"=="0" (
        set "unidad_origen=!unidad!:"
		rem echo Origen: !unidad_origen!
    )
    echo "!etiqueta!" | findstr /C:"!etiqueta_destino!" > nul
    if "!errorlevel!"=="0" (
        set "unidad_destino=!unidad!:"
    )
)

set r_origen="!unidad_origen!\!directorio_origen:~3!" 
set r_destino="!unidad_destino!\!directorio_destino:~3!"
set r_log="!unidad_destino!\!dir_log:~3!"

REM Comprueba existencia unidad origen
if not exist !unidad_origen! (
    echo Error: No se encontro origen, etiqueta: !unidad_origen!
    goto :finalizar
)

REM Comprueba existencia unidad destino
if not exist !unidad_destino! (
    echo Error: No se encontro destino, etiqueta: "!unidad_destino!"
    goto :finalizar
)

echo Origen de copia : !r_origen! 
echo Destino de copia: !r_destino!

REM verificar existencia del directorio de LOG
if not exist "!r_log!" (
	mkdir !r_log!
)
set r_log="!unidad_destino!\!dir_log:~3!\!fecha_hora!_!unidad_origen:~0,1!_!unidad_destino:~0,1!.log"


REM Realiza la copia de seguridad usando robocopy (/XN :: Excluir archivos más recientes.
robocopy "!r_origen!" "!r_destino!" /E /DCOPY:T /LOG+:"!r_log!" /TEE /NP /FP /XO /X

REM buscar recientes en Destino. Para ello se ensaya la copia (/L) a la inversa (destino a origen)
robocopy "!r_destino!" "!r_origen!" /E /DCOPY:T /NP /FP /XO /x /L | findstr reciente >> "!r_log!".aux


if exist !r_log!.aux (
	echo ===========================================================================
	echo     ATENCION: Ficheros editados, no han sido sobrescritos.
	type "!r_log!".aux 
	echo ===========================================================================
	type "!r_log!".aux >> "!r_log!"
	del  "!r_log!".aux
)	

:finalizar

pause
endlocal
exit /b %error%
