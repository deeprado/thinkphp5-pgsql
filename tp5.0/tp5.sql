
-- ----------------------------
-- Type structure for tablestruct
-- ----------------------------
DROP TYPE IF EXISTS "tp5"."tablestruct";
CREATE TYPE "tp5"."tablestruct" AS (
  "fields_key_name" varchar(100) COLLATE "pg_catalog"."default",
  "fields_name" varchar(200) COLLATE "pg_catalog"."default",
  "fields_type" varchar(20) COLLATE "pg_catalog"."default",
  "fields_length" int8,
  "fields_not_null" varchar(10) COLLATE "pg_catalog"."default",
  "fields_default" varchar(500) COLLATE "pg_catalog"."default",
  "fields_comment" varchar(1000) COLLATE "pg_catalog"."default"
);



-- ----------------------------
-- Function structure for pgsql_type
-- ----------------------------
DROP FUNCTION IF EXISTS "tp5"."pgsql_type"("a_type" varchar);
CREATE OR REPLACE FUNCTION "tp5"."pgsql_type"("a_type" varchar)
  RETURNS "pg_catalog"."varchar" AS $BODY$
DECLARE
     v_type varchar;
BEGIN
     IF a_type='int8' THEN
          v_type:='bigint';
     ELSIF a_type='int4' THEN
          v_type:='integer';
     ELSIF a_type='int2' THEN
          v_type:='smallint';
     ELSIF a_type='bpchar' THEN
          v_type:='char';
     ELSE
          v_type:=a_type;
     END IF;
     RETURN v_type;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;

-- ----------------------------
-- Function structure for table_msg
-- ----------------------------
DROP FUNCTION IF EXISTS "tp5"."table_msg"("a_table_name" varchar);
CREATE OR REPLACE FUNCTION "tp5"."table_msg"("a_table_name" varchar)
  RETURNS SETOF "tp5"."tablestruct" AS $BODY$
DECLARE
    v_ret tp5.tablestruct;
BEGIN
    FOR v_ret IN SELECT * FROM tp5.table_msg('tp5',a_table_name) LOOP
        RETURN NEXT v_ret;
    END LOOP;
    RETURN;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100
  ROWS 1000;

-- ----------------------------
-- Function structure for table_msg
-- ----------------------------
DROP FUNCTION IF EXISTS "tp5"."table_msg"("a_schema_name" varchar, "a_table_name" varchar);
CREATE OR REPLACE FUNCTION "tp5"."table_msg"("a_schema_name" varchar, "a_table_name" varchar)
  RETURNS SETOF "tp5"."tablestruct" AS $BODY$
DECLARE
     v_ret tp5.tablestruct;
     v_oid oid;
     v_sql varchar;
     v_rec RECORD;
     v_key varchar;
BEGIN
     SELECT
           pg_class.oid  INTO v_oid
     FROM
           pg_class
           INNER JOIN pg_namespace ON (pg_class.relnamespace = pg_namespace.oid AND lower(pg_namespace.nspname) = a_schema_name)
     WHERE
           pg_class.relname=a_table_name;
     IF NOT FOUND THEN
         RETURN;
     END IF;

     v_sql='
     SELECT
           pg_attribute.attname AS fields_name,
           pg_attribute.attnum AS fields_index,
           tp5.pgsql_type(pg_type.typname::varchar) AS fields_type,
           pg_attribute.atttypmod-4 as fields_length,
           CASE WHEN pg_attribute.attnotnull  THEN ''not null''
           ELSE ''''
           END AS fields_not_null,
           pg_attrdef.adsrc AS fields_default,
           pg_description.description AS fields_comment
     FROM
           pg_attribute
           INNER JOIN pg_class  ON pg_attribute.attrelid = pg_class.oid
           INNER JOIN pg_type   ON pg_attribute.atttypid = pg_type.oid
           LEFT OUTER JOIN pg_attrdef ON pg_attrdef.adrelid = pg_class.oid AND pg_attrdef.adnum = pg_attribute.attnum
           LEFT OUTER JOIN pg_description ON pg_description.objoid = pg_class.oid AND pg_description.objsubid = pg_attribute.attnum
     WHERE
           pg_attribute.attnum > 0
           AND attisdropped <> ''t''
           AND pg_class.oid = ' || v_oid || '
     ORDER BY pg_attribute.attnum' ;

     FOR v_rec IN EXECUTE v_sql LOOP
         v_ret.fields_name=v_rec.fields_name;
         v_ret.fields_type=v_rec.fields_type;
         IF v_rec.fields_length > 0 THEN
            v_ret.fields_length:=v_rec.fields_length;
         ELSE
            v_ret.fields_length:=NULL;
         END IF;
         v_ret.fields_not_null=v_rec.fields_not_null;
         v_ret.fields_default=v_rec.fields_default;
         v_ret.fields_comment=v_rec.fields_comment;
         SELECT constraint_name INTO v_key FROM information_schema.key_column_usage WHERE table_schema=a_schema_name AND table_name=a_table_name AND column_name=v_rec.fields_name;
         IF FOUND THEN
            v_ret.fields_key_name=v_key;
         ELSE
            v_ret.fields_key_name='';
         END IF;
         RETURN NEXT v_ret;
     END LOOP;
     RETURN ;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100
  ROWS 1000;
