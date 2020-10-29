CREATE OR REPLACE PACKAGE OPS$ANDES.PKG_EMP_EMPRESAS_OBTENER AS 

    --
    -- PROPOSITO: Operaciones para obtener empresas asociadas a un afiliado
    -- METODOS:
    --      PRC_OBTENER_EMP_EMPRESAS: obtener empresas asociadas a un afiliado
    -- HISTORIAL DE MODIFICACION
    -- Persona                          Fecha           Comentarios.
    -- -------------------------------- --------------- --------------------
    --                                  03/02/2020      Creacion del package
    -- Cesar Salas (VASS)               23/06/2020      Aplicacion de buenas practicas y modificacion base trivadis

  /*TIPOS DE DATOS*/
  TYPE V_CURSOR IS REF CURSOR;
  SUBTYPE ST_TIPO_NUMBER IS NUMBER(5); 
  SUBTYPE ST_TIPO_VARCHAR2_2 IS VARCHAR2(2 CHAR);
  SUBTYPE ST_TIPO_VARCHAR2_1 IS VARCHAR2(1 CHAR);
  SUBTYPE ST_TIPO_VARCHAR2_4 IS VARCHAR2(4 CHAR);
  SUBTYPE ST_TIPO_VARCHAR2_8 IS VARCHAR2(8 CHAR);
  SUBTYPE ST_TIPO_VARCHAR2_50 IS VARCHAR2(50 CHAR);
  /* TODO enter package declarations (types, exceptions, methods etc) here */ 
PROCEDURE PRC_OBTENER_EMP_EMPRESAS(P_PER_RUT     IN AFI_PERSONA.PER_RUT%TYPE,
                                   LISTAR_EMPRESAS OUT V_CURSOR) ; 
END PKG_EMP_EMPRESAS_OBTENER;