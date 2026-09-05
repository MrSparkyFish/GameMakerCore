//feather ignore all
 
/** Represents a logical query that can be run against a `TagContainer`. A query that succeeds is called a "match". Queries test the intersection
 * properties of another `TagContainer` and can look for 3 things: All tags match, at least 1 tag match, or no tag match.
 * *** 
 * For example, if you wanted to test is a particular tag container contained tags ((A && B) || (C)) && (!D), you would construct your query in the 
 * form ALL( ANY( ALL(A,B), ALL(C) ), NONE(D) );
 * @return {Struct.TagQuery} */
function TagQuery() constructor {
	
	
	///@ignore List of tags referenced by this query
	tagDictionary = [];
	
	///@ignore Stream representation of the hierarchical query
	queryTokenStream = [];
	
	///@ignore Description for this query. Useful for debugging
	description = undefined;
	
	///@ignore The query evaluator that can read and evaluate our token stream.
	evaluator = new TagQueryEvaluator(self);
	
	/** Returns the tag from the specified index
	 * @return {Struct.TagSpecifier} */
	static GetTagFromIndex = function(index) {
		return ArrayTryGetElement(tagDictionary, index, Tag_EmptyTag());
	}
	
	/** Builds a query expression into the specified `TagQueryExpression` using this query.
	 * @arg {Struct.TagQueryExpression} outExpr The expression to build into
	 * @return {Undefined} */
	static GetQueryExpression = function(outExpr) {
		//Build the query expr tree and return it
		evaluator.Reset();
		return evaluator.Read(outExpr);
	}
	
	/** Returns the description of this query
	 * @return {String} */
	static GetDescription = function() {
		return description;
	}
	
	/** Populate the specified array with all the tags in this query
	 * @arg {Array<Struct.TagSpecifier>} outTags The array to populate
	 * @return {Undefined} */
	static GetTagsInArray = function(outTags)  {
		ArrayAddAll(outTags, tagDictionary);
	}
	
	/** Returns an array of the tags involved in this query.
	 * @return {Array<Struct.TagSpecifier>} */
	static GetTags = function() {
		return tagDictionary;
	}
	
	/** Returns the length of the token stream for this query
	 * @return {Real} */
	static GetStreamLength = function() {
		return array_length(queryTokenStream);
	}	
	
	/** Set the user description for this query
	 * @arg {String} description The description to set
	 * @return {Undefined} */
	static SetDescription = function(description) {
		self.description = description;
	}
	
	/** Replaces existing tags with passed in tag. Doesn't modify expression logic. Useful for when you need to cache and update a requently used query
	 * @arg {Struct.TagSpecifier} inTag The new tag
	 * @return {Undefined} */
	static ReplaceTagFast = function(inTag) {
		array_resize(tagDictionary, 1);
		tagDictionary[0] = inTag;
	}
	
	/** Replaces existing tags with passed in tags. Doesn't modify expression logic. Useful for when you need to cache and update a requently used query
	 * @arg {Struct.TagContainer} tags The new tags to add
	 * @return {Undefined} */
	static ReplaceTagsFast = function(tags) {
		var len = tags.NumberOfTags();
		array_resize(tagDictionary, len);
		array_copy(tagDictionary, 0, tags.GetTags(), 0, len);
	}
	
	/** Builds this query with the given root expression and optional user description
	 * @arg {Struct.TagQueryExpression} rootExpression The root expression we use to build the query off of.
	 * @arg {String} description Optional description. Useful for debugging.
	 * @return {Undefined} */
	static Build = function(rootExpression, description) {
		self.description = description;
		array_resize(tagDictionary, 0);
		array_resize(queryTokenStream, 0);
		
		//Adding true to indicate the existence of a root expression
		array_push(queryTokenStream, true);
		
		//Emit the query
		rootExpression.EmitTokens(queryTokenStream, tagDictionary);
	}
	
	/** Resets this query to its default empty state
	 * @return {Undefined} */
	static Clear = function() {
		array_resize(tagDictionary, 0);
		array_resize(queryTokenStream, 0);
		description = undefined;
	}
	
	/** Returns `true` if this query is empty.
	 * @return {Bool} */
	static IsEmpty = function() {
		return (array_length(queryTokenStream) == 0);
	}
	
	/** Recursively checks an expression against the specified tags and returns `true` if the tags match the expression or `false` if they don't
	 * @arg {Struct.TagContainer} tags The tags to run against this query
	 * @return {Bool} */
	static Matches = function(tags) {
		if (IsEmpty()) {
			return false;
		}
		//Make sure the evaluator is reset
		evaluator.Reset();
		return evaluator.Evaluate(tags);
	}
}