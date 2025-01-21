SELECT workflowname,
       step_id,
       step_name,
       NULL as action_id,
       NULL as action_name,
       class_name
  FROM (WITH source_data
                 AS (SELECT workflowname,
                            xmltype.createxml (
                                REPLACE (
                                    a.descriptor,
                                    '<!DOCTYPE workflow PUBLIC "-//OpenSymphony Group//DTD OSWorkflow 2.8//EN" "http://www.opensymphony.com/osworkflow/workflow_2_8.dtd">'))
                                AS xml
                       FROM jiraworkflows a
                      WHERE a.descriptor LIKE
                                '%klases_nosaukums%')
        SELECT workflowname,
               '1' AS step_id,
               EXTRACTVALUE (s.xml, 'workflow/initial-actions/action/@name')
                   AS step_name,
               EXTRACTVALUE (VALUE (dtl), 'arg/text()') AS class_name
          FROM source_data s,
               TABLE (
                   XMLSEQUENCE (
                       s.xml.EXTRACT (
                           'workflow/initial-actions/action/results/unconditional-result/post-functions/function/arg[@name="class.name"]'))) dtl)
 WHERE class_name =
           'klases_nosaukums'
GROUP BY workflowname,
         step_id,
         step_name,
         class_name
UNION ALL
SELECT workflowname,
       step_id,
       step_name,
       action_id,
       action_name,
       class_name
  FROM (WITH source_data
                 AS (SELECT workflowname,
                            xmltype.createxml (
                                REPLACE (
                                    a.descriptor,
                                    '<!DOCTYPE workflow PUBLIC "-//OpenSymphony Group//DTD OSWorkflow 2.8//EN" "http://www.opensymphony.com/osworkflow/workflow_2_8.dtd">'))
                                AS xml
                       FROM jiraworkflows a
                      WHERE a.descriptor LIKE
                                '%klases_nosaukums%')
        SELECT workflowname,
               EXTRACTVALUE (VALUE (dtl2), 'step/@id') AS step_id,
               EXTRACTVALUE (VALUE (dtl2), 'step/@name') AS step_name,
               EXTRACTVALUE (VALUE (dtl3), 'action/@id') AS action_id,
               EXTRACTVALUE (VALUE (dtl3), 'action/@name') AS action_name,
               EXTRACTVALUE (VALUE (dtl4), 'arg/text()') AS class_name
          FROM source_data s,
               TABLE (XMLSEQUENCE (s.xml.EXTRACT ('workflow/steps/step'))) dtl2,
               TABLE (
                   XMLSEQUENCE (VALUE (dtl2).EXTRACT ('step/actions/action'))) dtl3,
               TABLE (
                   XMLSEQUENCE (
                       VALUE (dtl3).EXTRACT (
                           'action/results/unconditional-result/post-functions/function/arg[@name="class.name"]'))) dtl4)
 WHERE class_name =
           'klases_nosaukums'
GROUP BY workflowname,
         step_id,
         step_name,
         action_id,
         action_name,
         class_name
