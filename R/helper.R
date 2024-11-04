#TODO: encode in JSON config file?
.filterableFields <- list(
  "HARMONIZEDCATEGORY" = list(
    "label" = "Category",
    "multiple" = TRUE,
    "defaultValues" = NULL,
    "placeholder" = "Vaccines, Oncology, etc.",
    "tooltip" = "To select the Category that has the final responsibility for the study. Multiple choices possible."
  ),
  "STUDYSOP" = list(
    "label" = "SOP",
    "multiple" = TRUE,
    "defaultValues" = NULL,
    "placeholder" = "CT24, RC01, GNT01, etc.",
    "tooltip" = "To select a Pfizer study SOP (eg. CT24, CT45, RC01, GNT01) the study is conducted under. Multiple choices are possible.
                                     CT24 = Non-interventional study; primary or secondary data collection
                                     CT45 = Interventional study with minimal risk; low interventional study or pragmatic clinical trial
                                     RC01 = Research collaboration
                                     GNT01 = Independent research includes Investigator Sponsored Research (ISR) which involves Pfizer asset, and General Research which does not involve Pfizer asset."
  ),
  "STUDYSUBTYPE" = list(
    "label" = "Study Subtype",
    "multiple" = TRUE,
    "defaultValues" = NULL,
    "placeholder" = "LIS1, LIS2, etc.",
    "tooltip" = "To select the study subtype. Current options are subtypes for GNT01 (Investigator Sponsored Research or General research) and subtypes for CT45 (LIS 1 or LIS 2)"
  ),
  "EXECUTIONGROUP" = list(
    "label" = "Group Executing",
    "multiple" = TRUE,
    "defaultValues" = NULL,
    "placeholder" = "SSR, GME, RWE, etc.",
    "tooltip" = "Group responsible for operationalizing the study"
  ),
  "PASS" = list(
    "label" = "Is study a PASS?",
    "multiple" = TRUE,
    "defaultValues" = NULL,
    "placeholder" = "Yes or No, Committed or Voluntary",
    "tooltip" = "Is the study a voluntary or committed post approval safety study?"
  ),
  "PMS" = list(
    "label" = "Is study post marketing surveillance?",
    "multiple" = TRUE,
    "defaultValues" = NULL,
    "placeholder" = "Yes or No",
    "tooltip" = "Is the study a committed post marketing surveillance study?"
  ),
  "UNITEDSTATES" = list(
    "label" = "Study Conducted in the United States",
    "multiple" = TRUE,
    "defaultValues" = NULL,
    "placeholder" = "Yes or No",
    "tooltip" = "To select whether the study is conducted in the US or includes at least one study site in the US."
  ),
  "INTERNATIONALPRIORITY" = list(
    "label" = "Study Conducted in an International Priority Market?",
    "multiple" = TRUE,
    "defaultValues" = NULL,
    "placeholder" = "Yes or No",
    "tooltip" = "To select a market/country from the list of international priority markets/countries in which the study is conducted in. The list of international priority markets/countries contains 4 countries (Japan, China, France and Germany). Multiple choices are possible."
  ),
  "ANCHORMARKET" = list(
    "label" = "Study Conducted in an Anchor Market?",
    "multiple" = TRUE,
    "defaultValues" = NULL,
    "placeholder" = "Yes or No",
    "tooltip" = "To select a market/country from the list of anchor markets/countries in which the study is conducted in. The list of  anchor markets contains 12 markets/countries (Italy, Spain, Brazil, UK, Australia, India, Turkey, Saudi Arabia, Canada, South Korea, Russia and Mexico). Multiple choices are possible."
  ),
  "DRUGPRIORITY" = list(
    "label" = "Asset Priority",
    "multiple" = TRUE,
    "defaultValues" = NULL,
    "placeholder" = "Priority Asset, Launch Priority, etc.",
    "tooltip" = "To select the asset tier of interest. Pfizer categorises its assets into priorities of development and strategic alignment. Multiple choices possible. Attributes are:
                                    Priority asset = assets that are on market that have been prioritized by leadership
                                    Launch priority = assets that are to be launched that have been prioritized by leadership
                                    Tier 1 research priority = as affirmed by PRD and POD governance
                                    Tier 2 research priority = as affirmed by PRD and POD governance
                                    All other assets = assets that do not fall into the above categories
                                    No Pfizer drug"
  ),
  "HARMONIZEDPRIMARYDRUG" = list(
    "label" = "Pfizer Asset",
    "multiple" = TRUE,
    "defaultValues" = NULL,
    "placeholder" = "tofacitinib, palbociclib, etc.",
    "tooltip" = "To select a Pfizer asset which is used as the primary/main asset in the study. Multiple choices possible. Note: Values are provided as Compound number (e.g. PFE) or generic name. If generic name is used and the asset is a drug combination the generic names of the components are provided."
  ),
  "STATUS" = list(
    "label" = "Study Status",
    "multiple" = TRUE,
    "defaultValues" = c("Approved", "Concept", "Ongoing", "Pending", "Planned"),
    "placeholder"="Approved, Ongoing, etc.",
    "tooltip" = "To select where the study is in its life cycle. Please note: Study status values are specific for type of SOP. Multiple choices possible.
                                    For CT24 and CT45 the following values/attributes are possible:
                                    Planned: The study is due to start, as determined by the asset team (e.g., the protocol is in draft).
                                    Approved: The Final Approved Protocol (FAP) contains all required signatures and dates.
                                    Ongoing: First Subject First Visit (FSFV) has occurred (e.g., at least one subject has been enrolled and subjects are still being recruited, data collection has started).
                                    Completed: Last Subject Last Visit (LSLV) has occurred (e.g., the study has achieved the protocol specified End of Study, all data collection has ended).
                                    Cancelled: Study has been cancelled prior to any subjects being enrolled, or prior to the start of data collection.
                                    Terminated: The recruitment of new subjects has been stopped prematurely and there is no intention of restarting the study. The decision has been made to stop the study before reaching the protocol specified End of Study.
                                    For RC01 and GNT01 the Study status will depend on whether the study is in concept, contract or study  stage:
                                    Pending: Concept or protocol submission under review.
                                    Approved: Concept or protocol has been approved.
                                    Additional detail on specific GNT01 study status is available in the study list under Study Status Details."
  ),
  "STATUSDETAIL" = list(
    "label" = "Study Status Detail",
    "multiple" = TRUE,
    "defaultValues" = NULL,
    "placeholder" = "Contract Executed, In Contracting, etc.",
    "tooltip" = "To select more detailed status information about the study status. Multiple choices possible."
  ),
  "COUNTRIESOFSTUDY" = list(
    "label" = "Study Country(s)",
    "multiple" = TRUE,
    "defaultValues" = NULL,
    "placeholder" = "China, France, etc.",
    "tooltip" = "To select the country or countries where the study is conducted"
  )
)

.mainStudyTableColumnSpecifications <- list(
  "NAME" = list(
    "name" = "ID",
    "sticky" = "left",
    minWidth = 150
  ),
  "TITLE" = list(
    "name" = "Title",
    "sticky" = "left",
    minWidth = 350
  ),
  "STUDYTYPE" = list(
    "name" = "Study Type",
    minWidth = 150
  ),
  "STUDYSOP" = list(
    "name" = "SOP",
    minWidth = 150
  ),
  "STUDYSUBTYPE" = list(
    "name" = "Study Subtype",
    minWidth = 150
  ),
  "PASS" = list(
    "name" = "PASS",
    minWidth = 150
  ),
  "PMS" = list(
    "name" = "Post Marketing Surveillance",
    minWidth = 150
  ),
  "HARMONIZEDCATEGORY" = list(
    "name" = "Category",
    minWidth = 150
  ),
  "INDICATION" = list(
    "name" = "Indication",
    minWidth = 150
  ),
  "HARMONIZEDPRIMARYDRUG" = list(
    "name" = "Primary Drug",
    minWidth = 150
  ),
  "DRUGPRIORITY" = list(
    "name" = "Asset Priority",
    minWidth = 150
  ),
  "STATUS" = list(
    "name" = "Status",
    minWidth = 150
  ),
  "STATUSDETAIL" = list(
    "name" = "Status Detail",
    minWidth = 150
  ),
  "COUNTRIESOFSTUDY" = list(
    "name" = "Study Country(s)",
    minWidth = 150
  ),
  "UNITEDSTATES" = list(
    "name" = "Study Conducted in United States",
    minWidth = 150
  ),
  "INTERNATIONALPRIORITY" = list(
    "name" = "Study Conducted in International Priority Market",
    minWidth = 250
  ),
  "ANCHORMARKET" = list(
    "name" = "Study Conducted in Anchor Market",
    minWidth = 150
  ),
  "EXECUTIONGROUP" = list(
    "name" = "Group Operationalizing",
    minWidth = 150
  ),
  "SPONSORINGDIVISION" = list(
    "name" = "Sponsoring Division",
    minWidth = 150
  )
)


