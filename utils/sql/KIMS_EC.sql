WITH bow_orig_data AS (
    SELECT
        NAME,
        CREATED_BY,
        DATE_CREATED,
        UPDATED_BY,
        DATE_UPDATED,
        TITLE,
        STUDYTYPE,
        SPONSORINSTITUTION,
        SPONSORINGDIVISION,
        SPONSORINGUNIT,
        CATEGORY,
        INDICATION,
        PRIMARYDRUG,
        PFECOMPOUND,
        STATUS,
        PASS,
        PMS,
        HTASUBMISSION,
        REGULATORYSUBMISSION,
        RISKSTUDY,
        RISKTYPE,
        RISKDESCRIPTION,
        RISKMITIGATIONPLAN,
        EXECUTIONGROUP,
        EVIDENCELEAD,
        STUDYOPSLEAD,
        CLINICALSCIENTISTRWE,
        RWESCIENTIST,
        RWESTRATEGIST,
        QUALITYANDCOMPLAINCE,
        STATISTICIAN,
        MEDICALAFFAIRS,
        EVIDENCESOURCE,
        TRANSITIONPLAN,
        STUDYSOP,
        PRIMARYDATACOLLECTION,
        SECONDARYDATACOLLECTION,
        STUDYSUBTYPE
    FROM
        rwd_prod.team_evgen.kims_bow_evidence_catalog
),
study_countries AS (
    SELECT
        country_union.NAME,
        COALESCE(LISTAGG(DISTINCT country_union.COUNTRIESOFSTUDY, '|'), '') AS COUNTRIESOFSTUDY
    FROM (
        SELECT
            NAME,
            TRIM(UPPER(COUNTRIESOFSTUDY)) AS COUNTRIESOFSTUDY
        FROM
            rwd_prod.team_evgen.kims_bow_evidence_catalog
        UNION
        SELECT
            NAME,
            TRIM(UPPER(PLANNEDSTUDYCOUNTRY)) AS COUNTRIESOFSTUDY
        FROM
            rwd_prod.team_evgen.kims_bow_evidence_catalog
        UNION
        SELECT
            NAME,
            TRIM(UPPER(COUNTRIESOFACTIVESTUDY)) AS COUNTRIESOFSTUDY
        FROM
            rwd_prod.team_evgen.kims_bow_evidence_catalog
        UNION
        SELECT
            NAME,
            TRIM(UPPER(COUNTRIESOFTERMINATEDSTUDY)) AS COUNTRIESOFSTUDY
        FROM
            rwd_prod.team_evgen.kims_bow_evidence_catalog
    ) AS country_union
    WHERE
        NOT country_union.COUNTRIESOFSTUDY IS NULL AND
        country_union.COUNTRIESOFSTUDY != ''
    GROUP BY
        country_union.NAME
)
SELECT
    bod.NAME,
    bod.CREATED_BY,
    bod.DATE_CREATED,
    bod.UPDATED_BY,
    bod.DATE_UPDATED,
    bod.TITLE,
    bod.STUDYTYPE,
    bod.SPONSORINSTITUTION,
    bod.SPONSORINGDIVISION,
    bod.SPONSORINGUNIT,
    bod.CATEGORY,
    bod.INDICATION,
    bod.PRIMARYDRUG,
    bod.PFECOMPOUND,
    bod.STATUS,
    bod.PASS,
    bod.PMS,
    bod.HTASUBMISSION,
    bod.REGULATORYSUBMISSION,
    sc.COUNTRIESOFSTUDY,
    CASE
        WHEN UPPER(sc.COUNTRIESOFSTUDY) like '%UNITED%STATES%' THEN 'Yes'
        ELSE 'No'
    END as UnitedStates,
    CASE
        WHEN UPPER(sc.COUNTRIESOFSTUDY) like '%FRANCE%' THEN 'Yes'
        WHEN UPPER(sc.COUNTRIESOFSTUDY) like '%GERMANY%' THEN 'Yes'
        WHEN UPPER(sc.COUNTRIESOFSTUDY) like '%JAPAN%' THEN 'Yes'
        WHEN UPPER(sc.COUNTRIESOFSTUDY) like '%CHINA%' THEN 'Yes'
        ELSE 'No'
    END as InternationalPriority,
    CASE
        WHEN UPPER(sc.COUNTRIESOFSTUDY) like '%CANADA%' THEN 'Yes'
        WHEN UPPER(sc.COUNTRIESOFSTUDY) like '%MEXICO%' THEN 'Yes'
        WHEN UPPER(sc.COUNTRIESOFSTUDY) like '%BRAZIL%' THEN 'Yes'
        WHEN UPPER(sc.COUNTRIESOFSTUDY) like '%UNITED%KING%' THEN 'Yes'
        WHEN UPPER(sc.COUNTRIESOFSTUDY) like '%SPAIN%' THEN 'Yes'
        WHEN UPPER(sc.COUNTRIESOFSTUDY) like '%ITALY%' THEN 'Yes'
        WHEN UPPER(sc.COUNTRIESOFSTUDY) like '%TURKEY%' THEN 'Yes'
        WHEN UPPER(sc.COUNTRIESOFSTUDY) like '%SAUDI%' THEN 'Yes'
        WHEN UPPER(sc.COUNTRIESOFSTUDY) like '%KOREA%' THEN 'Yes'
        WHEN UPPER(sc.COUNTRIESOFSTUDY) like '%AUSTRALIA%' THEN 'Yes'
        WHEN UPPER(sc.COUNTRIESOFSTUDY) like '%INDIA%' THEN 'Yes'
        WHEN UPPER(sc.COUNTRIESOFSTUDY) like '%RUSSIA%' THEN 'Yes'
        ELSE 'No'
    END as AnchorMarket,
    bod.RISKSTUDY,
    bod.RISKTYPE,
    bod.RISKDESCRIPTION,
    bod.RISKMITIGATIONPLAN,
    bod.EXECUTIONGROUP,
    bod.EVIDENCELEAD,
    bod.STUDYOPSLEAD,
    bod.CLINICALSCIENTISTRWE,
    bod.RWESCIENTIST,
    bod.RWESTRATEGIST,
    bod.QUALITYANDCOMPLAINCE,
    bod.STATISTICIAN,
    bod.MEDICALAFFAIRS,
    bod.EVIDENCESOURCE,
    bod.TRANSITIONPLAN,
    bod.STUDYSOP,
    bod.PRIMARYDATACOLLECTION,
    bod.SECONDARYDATACOLLECTION,
    bod.STUDYSUBTYPE
FROM
    bow_orig_data bod
    LEFT JOIN study_countries sc ON
        sc.NAME = bod.NAME;
