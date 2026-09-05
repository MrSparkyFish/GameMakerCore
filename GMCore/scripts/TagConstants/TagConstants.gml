//feather ignore all
 
//The message levels that the tag module is allowed to log
#macro TAG_LOG_DEBUG 	true
#macro TAG_LOG_WARNING 	true
#macro TAG_LOG_ERROR 	true

/// Indicates the type of matching used
/// by a query expression.
enum TagQueryExpressionType {
	unset,										//Represents nothing
	anyTagsMatch,								//Any tag must match to return true. Uses TagSpecifier.MatchesTag
	allTagsMatch,								//All tags must match to return true. Uses TagSpecifier.MatchesTag
	noTagsMatch,								//No tags must match to return true. Uses TagSpecifier.MatchesTag
	anyExprMatch,								//Any TagQueryExpression must match
	allExprMatch,								//All TagQueryExpressions must match
	noExprMatch,								//No TagQueryExxpressions must match
	anyTagsMatchExact,							//Uses TagSpecifier.MatchesTagExact
	allTagsMatchExact,							//Uses TagSpecifier.MatchesTagExact
}