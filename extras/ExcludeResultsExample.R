allCohorts <- IbdCharacterization::getAllStudyCohortsWithDetails()
kidneyCohorts <- allCohorts[allCohorts$strataCohortName %in% c("Prevalent chronic kidney disease", "Prevalent chronic kidney disease broad"), ]
IbdCharacterization::exportResults("E:/IbdCharacterization/DATABASE_ID", "DATABASE_ID", kidneyCohorts$cohortId)
