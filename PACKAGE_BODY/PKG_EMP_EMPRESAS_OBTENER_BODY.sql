create or replace PACKAGE BODY OPS$ANDES.PKG_EMP_EMPRESAS_OBTENER AS

  PROCEDURE PRC_OBTENER_EMP_EMPRESAS(P_PER_RUT     IN AFI_PERSONA.PER_RUT%TYPE,
                                   LISTAR_EMPRESAS OUT V_CURSOR)  AS
        V_PER_RUT AFI_PERSONA.PER_RUT%TYPE := P_PER_RUT;
        EXISTE_PERSONA AFI_PERSONA.PER_RUT%TYPE;
      C_VCERO       CONSTANT PKG_EMP_EMPRESAS_OBTENER.ST_TIPO_NUMBER:= 0;  
      C_VDOS        CONSTANT PKG_EMP_EMPRESAS_OBTENER.ST_TIPO_NUMBER:= 2;
      C_VSEIS       CONSTANT PKG_EMP_EMPRESAS_OBTENER.ST_TIPO_NUMBER:= 6;
      C_VOCHO       CONSTANT PKG_EMP_EMPRESAS_OBTENER.ST_TIPO_NUMBER:= 8;
      C_VSSEIS       CONSTANT PKG_EMP_EMPRESAS_OBTENER.ST_TIPO_VARCHAR2_1:= '6';
      C_VSOCHO       CONSTANT PKG_EMP_EMPRESAS_OBTENER.ST_TIPO_VARCHAR2_1:= '8';
      C_VESPACIO    CONSTANT PKG_EMP_EMPRESAS_OBTENER.ST_TIPO_VARCHAR2_1:= ' ';
      C_VAFI       CONSTANT PKG_EMP_EMPRESAS_OBTENER.ST_TIPO_VARCHAR2_8:= 'Afiliado'; 
      
       --VALOR DE EXCEPCIONES
    V_PER_RUT_EXCEPTION_NO_VALIDO EXCEPTION;   
    V_PER_SUM_EXCEPTION_NO_VAL_COD CONSTANT PKG_PCA_CARGA_OBTENER.ST_TIPO_NUMBER:= -20010;
    V_PER_SUM_EXCEPTION_MO_VAL_MSG CONSTANT PKG_PCA_CARGA_OBTENER.ST_TIPO_VARCHAR2_50:= 'RUT DE PERSONA NO VALIDO';
    V_PER_RUT_EXCEPTION_NULL EXCEPTION;
    V_PER_RUT_EXCEPTION_NULL_COD CONSTANT PKG_PCA_CARGA_OBTENER.ST_TIPO_NUMBER:= -20001;
    V_PER_RUT_EXCEPTION_NULL_MSG CONSTANT PKG_PCA_CARGA_OBTENER.ST_TIPO_VARCHAR2_50:= 'RUT DE PERSONA NULL';
	
	-- EXCEPCIONES RECUPERA VARIAS FILAS
	V_TOO_MANY_ROWS_EXCEPTION_COD CONSTANT PKG_PCA_CARGA_OBTENER.ST_TIPO_NUMBER:= -20001;
    V_TOO_MANY_ROWS_EXCEPTION_MSG CONSTANT PKG_PCA_CARGA_OBTENER.ST_TIPO_VARCHAR2_50:= 'RECUPERA VARIAS FILAS';
	
	-- EXCEPCIONES DATOS NO ENCONTRADOS
	V_NO_DATA_FOUND_EXCEPTION_COD CONSTANT PKG_PCA_CARGA_OBTENER.ST_TIPO_NUMBER:= -20001;
    V_NO_DATA_FOUND_EXCEPTION_MSG CONSTANT PKG_PCA_CARGA_OBTENER.ST_TIPO_VARCHAR2_50:= 'DATOS NO ENCONTRADOS';
	
	-- EXCEPCIONES OTRAS
    V_OTHER_EXCEPTION_COD CONSTANT PKG_PCA_RENTINFORMADAS_OBTENER.ST_TIPO_NUMBER:= -20020;
  BEGIN
    
    <<VALIDA_EXISTE_RUT>>
    BEGIN
          SELECT  per.per_rut
            INTO EXISTE_PERSONA
            FROM afi_persemp pem 
             JOIN afi_empresa emp 
                  ON emp.emp_rut = pem.emp_rut 
             JOIN afi_persona per 
                  ON per.per_rut = pem.per_rut 
             JOIN afi_sucuremp sem  
                  ON sem.emp_rut = pem.emp_rut AND   sem.sem_sucemp = pem.sem_sucemp 
             LEFT OUTER JOIN tit  
                  ON  tit.tit_codigo = pem.tit_tiptra
             WHERE per.PER_RUT = V_PER_RUT and eaf_estafi=C_VAFI AND ROWNUM=1;
         EXCEPTION
              WHEN NO_DATA_FOUND THEN
                RAISE_APPLICATION_ERROR(V_NO_DATA_FOUND_EXCEPTION_COD,V_NO_DATA_FOUND_EXCEPTION_MSG);
              WHEN TOO_MANY_ROWS THEN
                RAISE_APPLICATION_ERROR(V_TOO_MANY_ROWS_EXCEPTION_COD,V_TOO_MANY_ROWS_EXCEPTION_MSG);
              WHEN OTHERS THEN
                RAISE_APPLICATION_ERROR(V_OTHER_EXCEPTION_COD, SQLERRM);  
    END VALIDA_EXISTE_RUT;
    
    IF P_PER_RUT IS NULL THEN -- VALIDA RUT PERSONA NO SEA NULO
        RAISE_APPLICATION_ERROR(V_PER_RUT_EXCEPTION_NULL_COD,V_PER_RUT_EXCEPTION_NULL_MSG);
    ELSE     
         -- TAREA: Se necesita implantación para PROCEDURE PKG_EMP_EMPRESAS_OBTENER.PRC_OBTENER_PER_EMPRESAS
        OPEN LISTAR_EMPRESAS FOR
            SELECT  
                pem.emp_rut                             as rut, 
                emp.emp_digito                          as digitoVerificador,
                emp.emp_razsoc                          as razonSocial,
                nvl(sem.sem_tottra,C_VCERO)             as cantidadTrabajadores,
                'true'                                 as esAfiliado,
                pem.sem_sucemp                          as codigo,
                ' '                                as nombre,
                sem.sem_calle || C_VESPACIO || sem.sem_numdir  as descripcion,
                pem.pem_feccon                              as fechaContrato,  ---salida
                --pca.VCAT_DESCRIPCION as tipoAfiliado --salida
                CASE nvl(pem.tit_tiptra,C_VDOS)
                WHEN C_VSSEIS THEN 
                    C_VSEIS
                WHEN C_VSOCHO THEN
                    C_VOCHO
                ELSE C_VDOS 
                END AS tipoAfiliado
            FROM afi_persemp pem 
                 JOIN afi_empresa emp 
                      ON emp.emp_rut = pem.emp_rut 
                 JOIN afi_persona per 
                      ON per.per_rut = pem.per_rut 
                 JOIN afi_sucuremp sem  
                      ON sem.emp_rut = pem.emp_rut AND   sem.sem_sucemp = pem.sem_sucemp 
                 LEFT OUTER JOIN tit  
                      ON  tit.tit_codigo = pem.tit_tiptra
        WHERE  
             per.per_rut =P_PER_RUT     AND   
             --  sem.ESA_AFIlia='Afiliada' AND    
             eaf_estafi=C_VAFI;
    END IF;
    EXCEPTION 
        WHEN V_PER_RUT_EXCEPTION_NULL THEN
            RAISE_APPLICATION_ERROR(V_PER_RUT_EXCEPTION_NULL_COD,V_PER_RUT_EXCEPTION_NULL_MSG);
        WHEN V_PER_RUT_EXCEPTION_NO_VALIDO THEN
            RAISE_APPLICATION_ERROR(V_PER_SUM_EXCEPTION_NO_VAL_COD,V_PER_SUM_EXCEPTION_MO_VAL_MSG);
        WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(V_OTHER_EXCEPTION_COD, SQLERRM); 
         
  END PRC_OBTENER_EMP_EMPRESAS;

END PKG_EMP_EMPRESAS_OBTENER;