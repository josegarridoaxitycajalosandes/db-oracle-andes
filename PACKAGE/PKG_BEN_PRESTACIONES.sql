CREATE OR REPLACE PACKAGE OPS$ANDES.PKG_BEN_PRESTACIONES AS 
    --
    -- PROPOSITO: Operaciones para obtener lista de planes de un afiliado
    -- METODOS:
    --      PRD_GET_PLANES: Obtener los planes de un afiliado
    -- HISTORIAL DE MODIFICACION
    -- Persona                          Fecha           Comentarios.
    -- -------------------------------- --------------- --------------------
    -- Cesar Salas (VASS)       03/02/2020      Creacion del package

    SUBTYPE ST_TIPO_VARCHAR2_6 IS VARCHAR2(6 CHAR);
    SUBTYPE ST_TIPO_VARCHAR2_8 IS VARCHAR2(8 CHAR);
    SUBTYPE ST_TIPO_VARCHAR2_10 IS VARCHAR2(10 CHAR);
    SUBTYPE ST_TIPO_VARCHAR2_500 IS VARCHAR2(500 CHAR);
    SUBTYPE ST_TIPO_VARCHAR2_200 IS VARCHAR2(200 CHAR);
    SUBTYPE ST_TIPO_NUMBER IS NUMBER(15);
    TYPE V_CURSOR IS REF CURSOR;
    
    PROCEDURE PRD_GET_PLANES(P_PER_RUT IN ppc_perconpla.per_rut%TYPE,
                            V_OBTIENE_PLANES OUT V_CURSOR);

END PKG_BEN_PRESTACIONES;