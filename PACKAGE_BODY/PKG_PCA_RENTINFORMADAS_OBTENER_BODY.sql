create or replace PACKAGE BODY           OPS$ANDES.PKG_PCA_RENTINFORMADAS_OBTENER AS

  PROCEDURE PRC_OBTENER_PCA_RENTINFORMADAS (P_PER_RUT IN afi_persona.per_rut%type,
                                       V_RENTINFORMADAS    OUT V_CURSOR) as
                                       
  V_PER_RUT_EXCEPTION_NO_VALIDO EXCEPTION;    
  V_PER_SUM_EXCEPTION_NO_VAL_COD CONSTANT PKG_PCA_RENTINFORMADAS_OBTENER.ST_TIPO_NUMBER:= -20010;
  V_PER_SUM_EXCEPTION_MO_VAL_MSG CONSTANT PKG_PCA_RENTINFORMADAS_OBTENER.ST_TIPO_VARCHAR2_50:= 'RUT DE PERSONA NO VALIDO';
  V_PER_RUT_EXCEPTION_NULL EXCEPTION;
  V_PER_RUT_EXCEPTION_NULL_COD CONSTANT PKG_PCA_RENTINFORMADAS_OBTENER.ST_TIPO_NUMBER:= -20001;
  V_PER_RUT_EXCEPTION_NULL_MSG CONSTANT PKG_PCA_RENTINFORMADAS_OBTENER.ST_TIPO_VARCHAR2_50:= 'RUT DE PERSONA NULL';  

  -- EXCEPCIONES RECUPERA VARIAS FILAS
  V_TOO_MANY_ROWS_EXCEPTION_COD CONSTANT PKG_PCA_RENTINFORMADAS_OBTENER.ST_TIPO_NUMBER:= -20001;
  V_TOO_MANY_ROWS_EXCEPTION_MSG CONSTANT PKG_PCA_RENTINFORMADAS_OBTENER.ST_TIPO_VARCHAR2_50:= 'RECUPERA VARIAS FILAS';  
  
  -- EXCEPCIONES DATOS NO ENCONTRADOS
  V_NO_DATA_FOUND_EXCEPTION_COD CONSTANT PKG_PCA_RENTINFORMADAS_OBTENER.ST_TIPO_NUMBER:= -20001;
  V_NO_DATA_FOUND_EXCEPTION_MSG CONSTANT PKG_PCA_RENTINFORMADAS_OBTENER.ST_TIPO_VARCHAR2_50:= 'DATOS NO ENCONTRADOS';
  
  -- EXCEPCIONES OTHER
  V_EXCEPTION_VAL_COD_OTHER CONSTANT PKG_PCA_RENTINFORMADAS_OBTENER.ST_TIPO_NUMBER:= -20020;
	
  EXISTE_PERSONA PKG_PCA_RENTINFORMADAS_OBTENER.ST_TIPO_NUMBER_9;
  C_TRESSEISCINCO CONSTANT PKG_PCA_RENTINFORMADAS_OBTENER.ST_TIPO_NUMBER:= 365;
  C_FORMAT_FECHA CONSTANT PKG_PCA_RENTINFORMADAS_OBTENER.ST_TIPO_VARCHAR2_10:= 'dd-mm-yyyy'; 
  C_FONASA CONSTANT PKG_PCA_RENTINFORMADAS_OBTENER.ST_TIPO_VARCHAR2_10:= 'Fonasa';
  C_ISAPRE CONSTANT PKG_PCA_RENTINFORMADAS_OBTENER.ST_TIPO_VARCHAR2_10:= 'Isapre';
 
    

  BEGIN
    -- TAREA: Se necesita implantación para PROCEDURE PKG_PCA_RENTINFORMADAS_OBTENER.PRC_OBTENER_PCA_RENTINFORMADAS
     <<prepare_data>>
     BEGIN  
        SELECT PER_RUT INTO EXISTE_PERSONA FROM cot_hisdet WHERE PER_RUT = P_PER_RUT;
    EXCEPTION
              WHEN NO_DATA_FOUND THEN
                EXISTE_PERSONA:= 0; 
				RAISE_APPLICATION_ERROR(V_NO_DATA_FOUND_EXCEPTION_COD,V_NO_DATA_FOUND_EXCEPTION_MSG);
              WHEN TOO_MANY_ROWS THEN
                -- Este caso es por que la tabla puede devolver una o mas filas asociadas al mismo rut
                EXISTE_PERSONA:=1; 
				RAISE_APPLICATION_ERROR(V_TOO_MANY_ROWS_EXCEPTION_COD,V_TOO_MANY_ROWS_EXCEPTION_MSG);
              WHEN OTHERS THEN
                RAISE_APPLICATION_ERROR(V_EXCEPTION_VAL_COD_OTHER, SQLERRM); 
     END prepare_data;
        <<process_data>>
     
    IF P_PER_RUT IS NULL THEN -- VALIDA RUT PERSONA NO SEA NULO
        RAISE_APPLICATION_ERROR(V_PER_RUT_EXCEPTION_NULL_COD,V_PER_RUT_EXCEPTION_NULL_MSG);
    ELSIF EXISTE_PERSONA = 0 THEN -- VALIDA QUE EXISTA RUT DE PERSONA EN AFI_PERSONA
		RAISE_APPLICATION_ERROR(V_PER_SUM_EXCEPTION_NO_VAL_COD,V_PER_SUM_EXCEPTION_MO_VAL_MSG);
    ELSE 
         OPEN V_RENTINFORMADAS FOR        
         SELECT   hld.emp_rut     AS rut, 
                      (select emp.emp_digito from afi_empresa emp where emp.emp_rut = hld.emp_rut)   AS digitoVerificador,
                      (select emp.emp_razsoc from afi_empresa emp where emp.emp_rut = hld.emp_rut) AS razonSocial,
                      CAST (to_char(hld.hld_periodo,C_FORMAT_FECHA)  as varchar2(20 CHAR)) AS periodo,    --Rentas Informadas
                      nvl(hld.hld_monnoisa,0) + nvl(hld.hld_monisa,0) AS rentaImponible,
                      nvl(hld.hld_diatra,0) AS diasTrabajados,           --Rentas Informadas
                      cast (decode(nvl(hld.hld_monisa,0), 0, C_FONASA, C_ISAPRE) as varchar2(10 CHAR)) AS descripcion    --Regimen de Salud
         FROM    cot_hisdet hld
         WHERE   hld.per_rut = P_PER_RUT
         AND     hld.hld_periodo BETWEEN (SYSDATE - C_TRESSEISCINCO) AND SYSDATE
         ORDER BY hld_periodo ASC;
      END IF;
      EXCEPTION
        WHEN V_PER_RUT_EXCEPTION_NO_VALIDO THEN
            RAISE_APPLICATION_ERROR(V_PER_SUM_EXCEPTION_NO_VAL_COD,V_PER_SUM_EXCEPTION_MO_VAL_MSG);
        WHEN V_PER_RUT_EXCEPTION_NULL THEN
            RAISE_APPLICATION_ERROR(V_PER_RUT_EXCEPTION_NULL_COD,V_PER_RUT_EXCEPTION_NULL_MSG);
        WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(V_EXCEPTION_VAL_COD_OTHER, SQLERRM); 

  END PRC_OBTENER_PCA_RENTINFORMADAS;

END PKG_PCA_RENTINFORMADAS_OBTENER;