//feather ignore all
 
/** Represents a query used to find and filter tags
 * @return {Struct.TagQueryExpression} */
function TagQueryExpression() constructor {
	
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
	
	///@ignore Container of all the TagQueryExpressions within this expression
	expressionList = [];							
	
	///@ignore List of tags for expression types that need it
	tagList = [];									
	
	///@ignore Type of expression this is
	expressionType = TagQueryExpressionType.unset;
	
	/////@ignore If this expression matches using its tagList
	//usesTags = false;								
	//
	/////@ignore If this expression matches using its expressionlist
	//usesExpressions = false;	
	
	/** Helper to set expression types
	 * @ignore
	 * @deprecated
	 * @arg {Enum.Tag_QueryExpression} exprType
	 * @return {Undefined} */
	static UseExpressions = function(exprType) {
		//usesExpressions = true;
		//expressionType = exprType;
	}
	
	/** Helper to set tag types
	 * @ignore
	 * @deprecated
	 * @arg {Enum.Tag_QueryExpression} exprType
	 * @return {Undefined} */
	static UseTags = function(exprType) {
		//usesTags = true;
		//expressionType = exprType;
	}
	
	/** Returns `true` if this expression uses an expression list
	 * @return {Bool} */
	static UsesExpressions = function() {
		INLINE;
		return ((expressionType == TagQueryExpressionType.allExprMatch) || (expressionType == TagQueryExpressionType.anyExprMatch) || (expressionType == TagQueryExpressionType.noExprMatch));
	}
	
	/** Returns `true` if this expression uses a tag list
	 * @return {Bool} */
	static UsesTags = function() {
		INLINE;
		return ((expressionType == TagQueryExpressionType.allTagsMatch) || (expressionType == TagQueryExpressionType.anyTagsMatch) || (expressionType == TagQueryExpressionType.allTagsMatchExact) || (expressionType == TagQueryExpressionType.anyTagsMatchExact) || (expressionType == TagQueryExpressionType.noTagsMatch));
	}
	
	/** Add an expression to this expression query
	 * @arg {Struct.TagQueryExpression} expr The expression to add
	 * @return {Struct.TagQueryExpression} */
	static AddExpression = function(expr) {
		//if (!usesTags) {
			//TagError("AddExpression", $"Attempting to add an expression to a TagQueryExpression that only uses tags.");
		//}
		array_push(expressionList, expr);
		//usesExpressions = true;
		return self;
	}
	
	/** Add a tag to this expression 
	 * @arg {Struct.TagSpecifier} tag The tag to add
	 * @return {Struct.TagQueryExpression} */
	static AddTag = function(tag) {
		//if (!usesTags) {
			//TagError("AddExpression", $"Attempting to add a tag to a TagQueryExpression that only uses expressions.");
		//}
		array_push(tagList, tag);
		//usesTags = true;
		return self;
	}
	
	/** Adds a tag to this expression using its name
	 * @arg {String} tagName The name of the tag to add
	 * @return {Undefined} */
	static AddNamedTag = function(tagName) {
		var tag = TagManager_Get().RequestTag();
		return AddTag(tag);
	}
	
	/** Add a tag to this expression 
	 * @arg {Struct.TagContainer} tags The tags to add
	 * @return {Struct.TagQueryExpression} */
	static AddTags = function(tags) {
		//if (!usesTags) {
			//TagError("AddExpression", $"Attempting to add a tag to a TagQueryExpression that only uses expressions.");
		//}
		ArrayAddAll(tagList, tags.GetTags());
		//usesTags = true;
		return self;
	}
	
	/** Returns a query expression that checks if a `TagContainer` contains tags (A && B) using expression
	 * @return {Struct.TagQueryExpression} */
	static AllExprMatch = function() {
		self.expressionType = TagQueryExpressionType.allExprMatch;
		return self;
		//if (usesExpressions || usesTags) {
			//var expr = new TagQueryExpression();
			//expr.UseExpressions(TagQueryExpressionType.allExprMatch);
			//return expr;			
		//}
		//else {
			//UseExpressions(TagQueryExpressionType.allExprMatch);
			//return self
		//}	
	}
	
	
	/** Returns a query expression that checks if a `TagContainer` contains tags (A && B)
	 * @return {Struct.TagQueryExpression} */	
	static AllTagsMatch = function() {
		self.expressionType = TagQueryExpressionType.allTagsMatch;
		return self;	
		//if (usesExpressions || usesTags) {
			//var expr = new TagQueryExpression();
			//expr.UseTags(TagQueryExpressionType.allTagsMatch);
			//return expr;			
		//}
		//else {
			//UseTags(TagQueryExpressionType.allTagsMatch);
			//return self
		//}	
	}
	
	/** Returns a query expression that checks if a `TagContainer` contains tags (A || B) using expressions
	 * @return {Struct.TagQueryExpression} */	
	static AnyExprMatch = function() {
		self.expressionType = TagQueryExpressionType.anyExprMatch;
		return self;	
		//if (usesExpressions || usesTags) {
			//var expr = new TagQueryExpression();
			//expr.UseExpressions(TagQueryExpressionType.anyExprMatch);
			//return expr;			
		//}
		//else {
			//UseExpressions(TagQueryExpressionType.anyExprMatch);
			//return self
		//}		
	}
	
	/** Returns a query expression that checks if a `TagContainer` contains tags (A || B)
	 * @return {Struct.TagQueryExpression} */	
	static AnyTagsMatch = function() {
		self.expressionType = TagQueryExpressionType.anyTagsMatch;
		return self;	
		//if (usesExpressions || usesTags) {
			//var expr = new TagQueryExpression();
			//expr.UseTags(TagQueryExpressionType.anyTagsMatch);
			//return expr;			
		//}
		//else {
			//UseTags(TagQueryExpressionType.anyTagsMatch);
			//return self
		//}		
	}
	
	/** Returns a query expression that checks if a `TagContainer` contains tags (!A) using expressions
	 * @return {Struct.TagQueryExpression} */	
	static NoExprMatch = function() {
		self.expressionType = TagQueryExpressionType.noExprMatch;
		return self;	
		//if (usesExpressions || usesTags) {
			//var expr = new TagQueryExpression();
			//expr.UseExpressions(TagQueryExpressionType.noExprMatch);
			//return expr;			
		//}
		//else {
			//UseExpressions(TagQueryExpressionType.noExprMatch);
			//return self
		//}			
	}
	
	/** Returns a query expression that checks if a `TagContainer` contains tags (!A)
	 * @return {Struct.TagQueryExpression} */	
	static NoTagsMatch = function() {
		self.expressionType = TagQueryExpressionType.noTagsMatch;
		return self;	
		//if (usesExpressions || usesTags) {
			//var expr = new TagQueryExpression();
			//expr.UseTags(TagQueryExpressionType.noTagsMatch);
			//return expr;				
		//}
		//else {
			//UseTags(TagQueryExpressionType.noTagsMatch);
			//return self;
		//}
	}
	
	/** Returns a query expression similar to `AllTagsMatch()` but doesn't check for parent of the tag.
	 * @return {Struct.TagQueryExpression} */
	static AllTagsMatchExact = function() {
		self.expressionType = TagQueryExpressionType.allTagsMatchExact;
		return self;	
		//if (usesExpressions || usesTags) {
			//var expr = new TagQueryExpression();
			//expr.UseTags(TagQueryExpressionType.allTagsMatchExact);
			//return expr;				
		//}
		//else {
			//UseTags(TagQueryExpressionType.allTagsMatchExact);
			//return self;
		//}		
	}
	
	/** Returns a query expression similar to `AnyTagsMatch()` but doesn't check for parent of the tag.
	 * @return {Struct.TagQueryExpression} */	
	static AnyTagsMatchExact = function() {
		self.expressionType = TagQueryExpressionType.anyTagsMatchExact;
		return self;	
		//if (usesExpressions || usesTags) {
			//var expr = new TagQueryExpression();
			//expr.UseTags(TagQueryExpressionType.anyTagsMatchExact);
			//return expr;				
		//}
		//else {
			//UseTags(TagQueryExpressionType.anyTagsMatchExact);
			//return self;
		//}		
	}
	
	/** Writes this expression to the provided token stream
	 * @arg {Array<Real>} tokenStream The stream to write to
	 * @arg {Array<Struct.TagSpecifier>} tagDictionary The dictionary to add our tags to.
	 * @return {Undefined} */
	static EmitTokens = function(tokenStream, tagDictionary) {
		//Emit expression type
		array_push(tokenStream, expressionType);
		
		//Emit the data if we are tag type
		if (UsesTags()) {
			//Emit the number of tags that we have.
			var numTags = array_length(tagList);
			array_push(numTags);
			
			for (var i = 0, index = -1, tag; i < numTags; i++) {
				tag = tagList[i];
				
				//Get the index of the tag if there is one already in the dictionary
				index = array_get_index(tagDictionary, tag);
				
				//If the tag isn't there, add it.
				if (index == -1) {
					index = ArrayAdd(tagDictionary, tag);
				}
				
				//Reserve index 255 for internal use, therefore max value is 254.
				if (index >= 255) {
					TagError("EmitTokens", $"Maximum number of tags exceeded for TagQueryExpression {self}");
				}
				
				//Emit the index of each tag to the stream.
				array_push(tokenStream, index);
			}
		}
		
		//Emit data if we are expression type
		else if (UsesExpressions()) {
			//Emit the number of expressions we have
			var numExpr = array_length(expressionList);
			array_push(tokenStream, numExpr);
			
			//Emit the index of each expression
			for (var i = 0, e; i < numExpr; i++) {
				expressionList[i].EmitTokens(tokenStream, tagDictionary);
			}
		}
	}
	
	/** Recursively populates an array with the tags found in this expression.
	 * @arg {Array<Struct.TagSpecifiers>} outTags The array to populate with tags
	 * @return {Undefined} */
	static GetTags = function(outTags) {
		ArrayAddAll(outTags, tagList);
		//if (usesTags) {
			//ArrayPushUnique(tags, tagList[i++]);
		//}
		//else if (usesExpressions) {
			//var i = 0; repeat(array_length(expressionList)) {
				//expressionList[i++].GetTags(tags);
			//}
		//}
	}
}