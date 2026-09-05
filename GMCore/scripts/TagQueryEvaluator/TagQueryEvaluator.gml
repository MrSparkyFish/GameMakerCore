//feather ignore all

/** Helper class that runs the actual query matching logic.
 * ***
 * Implements: `IIterator`
 * @arg {Struct.TagQuery} tagQuery The query owned by this evaluator
 * @return {Struct.TagQueryEvaluator} */
function TagQueryEvaluator(tagQuery) constructor {
	///@ignore The query that we evaluate
	query = tagQuery;
	
	///@ignore The current stream index for reading
	currentStreamIndex = 0;
	
	///@ignore True if we ran into a read error.
	readError = false;
	
	
	/** Returns `true` if there's at least one more token to read.
	 * @ignore
	 * @return {Bool} */
	static HasNext = function() {
		return ArrayIsIndexInBounds(query.queryTokenStream, currentStreamIndex);
	}	
	
	/** Returns the next token in the stream
	 * @ignore
	 * @return {Real} */
	static Next = function() {
		if (HasNext()) {
			return query.queryTokenStream[currentStreamIndex++];
		}
		
		if (TAG_LOG_DEBUG) {
			LogDebug($"Reached end of TagQuery token stream.");
		}
		
		readError = true;
		return 0;
	}	
	
	/** Reset the evaluator.
	 * @return {Undefined} */
	static Reset = function() {
		readError = false;
		currentStreamIndex = 0;
	}
	
	/** Internal logic EvaluateExpression
	 * @ignore
	 * @arg {Struct.TagContainer} tagContainer The tags to evaluate
	 * @arg {Bool} skip If the evaluation should be skipped
	 * @return {Bool} */
	static EvaluateInternal = function(tags, skip) {
		var exprType = Next();
		
		if (readError) {
			return false;
		}
		
		
		//Evaluate the expression for the expression type
		switch (exprType) {
			case TagQueryExpressionType.anyTagsMatch:
				return EvaluateAnyTagsMatch(tags, skip);
			break;
			case TagQueryExpressionType.allTagsMatch:
				return EvaluateAllTagsMatch(tags, skip);
			break;
			case TagQueryExpressionType.noTagsMatch:
				return EvaluateNoTagsMatch(tags, skip);
			break;
			case TagQueryExpressionType.anyTagsMatchExact:
				return EvaluateAnyTagsExactMatch(tags, skip);
			break;
			case TagQueryExpressionType.allTagsMatchExact:
				return EvaluateAllTagsExactMatch(tags, skip);
			break;
			case TagQueryExpressionType.anyExprMatch:
				return EvaluateAnyExprMatch(tags, skip);
			break;
			case TagQueryExpressionType.allExprMatch:
				return EvaluateAllExprMatch(tags, skip);
			break;
			case TagQueryExpressionType.noExprMatch:
				return EvaluateNoExprMatch(tags, skip);
			break;
			default:
				return false;
			break;
		}
	}
	
	/** Internal logic ReadExpression
	 * @ignore
	 * @arg {Struct.TagQueryExpression} expression The expression to read
	 * @return {Undefined} */
	static ReadInternal = function(expression) {
		expression.expressionType = Next();
		
		//Don't do work if there's nothing to read.
		if (!readError) {
			//Parse tags
			if (expression.UsesTags()) {
				var numTags = Next();
				
				//Calling Next() can change readError flag; check it again.
				if (!readError) {
					for (var i = 0, tagIndex; i < numTags; i++) {
						tagIndex = Next();
						
						//Check again
						if (!readError) {
							//Add the tag from the stream to the expression.
							var tag = query.GetTagFromIndex(tagIndex);
							expression.AddTag(tag);
						}
					}
				}
			}
			//Parse expression
			else {
				var numExpr = Next();
				
				if (!readError) {
					for (var i = 0, exprIndex, expr; i < numExpr; i++) {
						//instantiate the next expression to read into
						expr = new TagQueryExpression();
						ReadInternal(expr);
						
						//Add the created expression to the previous one and continue.
						expression.AddExpression(expr);
					}
				}
			}
		}
	}		
	
	/** Evaluates the query against the specified tag container and returns `true` if the tags match this query.
	 * @arg {Struct.TagContainer} tags The tags to evaluate
	 * @return {Bool} */
	static Evaluate = function(tags) {
		//Make sure our index is reset so we have a fresh evaluation session
		currentStreamIndex = 0;
		
		//Early exit if cant read
		if (readError) {
			return false;
		}
		
		var matches = false;
		var hasRootExpression = Next();
		
		//Check read error again, `Next()` may have changed it.
		if (!readError && hasRootExpression) {
			matches = EvaluateInternal(tags);
		}		
		
		//Progress message for debug
		if (TAG_LOG_DEBUG) {
			if (currentStreamIndex == array_length(query.queryTokenStream)) {
				LogDebug($"Finished query evaluation");
			}
		}
		return matches;
	}
	
	/** Parses the token stream into the provided `TagQueryExpression`
	 * @arg {Struct.TagQueryExpression} expression
	 * @return {Undefined} */
	static Read = function(expression) {
		//Reset to default state so we have a fresh read session.
		currentStreamIndex = 0;
		
		//Reading the expression
		var streamLength = query.GetStreamLength();
		if (streamLength > 0) {
			if (!readError) {
				var hasRootExpression = Next();
				
				//Read error may have changed by the above `Next()` call
				if (!readError && hasRootExpression) {
					ReadInternal(expression);
				}
				
			}
			
			if (TAG_LOG_DEBUG) {
				if (currentStreamIndex == array_length(query.queryTokenStream)) {
					LogDebug($"Finished reading tokens for TagQuery");
				}
			}
		}
	}
	
	
	/** Returns `true` if at least one tag from the continer matches the query
	 * @ignore
	 * @arg {Struct.TagContainer} tags The tags to evaluate against this query
	 * @arg {Bool} skip Set true if this evaluation should not be executed
	 * @return {Bool} */
	static EvaluateAnyTagsMatch = function(tags, skip) {
		//Assume false until proven otherwise
		var matches = false;
		
		//Parse tags
		var numTags = Next();
		if (!readError) {
			
			//Loop through tags until we find 1 match
			for (var i = 0, tagIndex; i < numTags; i++) {
				tagIndex = Next();
				if (!readError) {
					//Need 1 matching tag to prove true
					if (!skip && tags.HasTag(query.GetTagFromIndex(tagIndex))) {
						//Dont return right away, need the for loop to run 1 more time so Next() can increment the token index in case of multiple expressions.
						skip = true;
						matches = true;
					}
				}
			}
		}
		
		return matches;
	}
	
	/** Returns `true` if all tags from the continer match the query
	 * @ignore
	 * @arg {Struct.TagContainer} tags The tags to evaluate against this query
	 * @arg {Bool} skip True if this evaluation should not be executed
	 * @return {Bool} */	
	static EvaluateAllTagsMatch = function(tags, skip) {
		//Assume true until proven otherwise
		var matches = true;
		
		//Parse tags
		var numTags = Next();
		if (!readError) {
			
			//Loop through tags until we find 1 match
			for (var i = 0, tagIndex; i < numTags; i++) {
				tagIndex = Next();
				if (!readError) {
					//Need 1 non-matching tag to prove false
					if (!skip && !tags.HasTag(query.GetTagFromIndex(tagIndex))) {
						//Dont return right away, need the for loop to run 1 more time so Next() can increment the token index in case of multiple expressions.
						skip = true;
						matches = false;
					}
				}
			}
		}
		
		return matches;	
	}
	
	/** Returns `true` if at least one tag from the continer exactly matches the query
	 * @ignore
	 * @arg {Struct.TagContainer} tags The tags to evaluate against this query
	 * @arg {Bool} skip True if this evaluation should not be executed
	 * @return {Bool} */	
	static EvaluateAnyTagsExactMatch = function(tags, skip) {
		//Assume false until proven otherwise
		var matches = false;
		
		//Parse tags
		var numTags = Next();
		if (!readError) {
			
			//Loop through tags until we find 1 match
			for (var i = 0, tagIndex; i < numTags; i++) {
				tagIndex = Next();
				if (!readError) {
					//Need 1 matching tag to prove false
					if (!skip && tags.HasTagExact(query.GetTagFromIndex(tagIndex))) {
						//Dont return right away, need the for loop to run 1 more time so Next() can increment the token index in case of multiple expressions.
						skip = true;
						matches = true;
					}
				}
			}
		}
		
		return matches;		
	}
	
	/** Returns `true` if all tags from the continer exactly match the query
	 * @ignore
	 * @arg {Struct.TagContainer} tags The tags to evaluate against this query
	 * @arg {Bool} skip True if this evaluation should not be executed
	 * @return {Bool} */	
	static EvaluateAllTagsExactMatch = function(tags, skip) {
		//Assume true until proven otherwise
		var matches = true;
		
		//Parse tags
		var numTags = Next();
		if (!readError) {
			
			//Loop through tags until we find 1 match
			for (var i = 0, tagIndex; i < numTags; i++) {
				tagIndex = Next();
				if (!readError) {
					//Need 1 matching tag to prove false
					if (!skip && tags.HasTagExact(query.GetTagFromIndex(tagIndex))) {
						//Dont return right away, need the for loop to run 1 more time so Next() can increment the token index in case of multiple expressions.
						skip = true;
						matches = false;
					}
				}
			}
		}
		
		return matches;			
	}
	
	/** Returns `true` if no tags from the continer matche the query
	 * @ignore
	 * @arg {Struct.TagContainer} tags The tags to evaluate against this query
	 * @arg {Bool} skip True if this evaluation should not be executed
	 * @return {Bool} */	
	static EvaluateNoTagsMatch = function(tags, skip) {
		//Assume true until proven otherwise
		var matches = true;
		
		//Parse tags
		var numTags = Next();
		if (!readError) {
			
			//Loop through tags until we find 1 match
			for (var i = 0, tagIndex; i < numTags; i++) {
				tagIndex = Next();
				if (!readError) {
					//Need 1 matching tag to prove false
					if (!skip && tags.HasTag(query.GetTagFromIndex(tagIndex))) {
						//Dont return right away, need the for loop to run 1 more time so Next() can increment the token index in case of multiple expressions.
						skip = true;
						matches = false;
					}
				}
			}
		}
		
		return matches;	
	}
	
	/** Returns `true` if at least one tag from the continer matches at least one expression in the query
	 * @ignore
	 * @arg {Struct.TagContainer} tags The tags to evaluate against this query
	 * @arg {Bool} skip True if this evaluation should not be executed
	 * @return {Bool} */	
	static EvaluateAnyExprMatch = function(tags, skip) {
		//Assume false until proven otherwise
		var matches = false;
		
		//Parse tags
		var numExpr = Next();
		if (!readError) {
			
			//Loop through tags until we find 1 match
			for (var i = 0, tagIndex, exprResult; i < numExpr; i++) {
				//Each expression MUST be evaluated then checked. Trying to do them in the same if statement as skip can result in the evaluation not triggering properly.
				exprResult = EvaluateInternal(tags, skip);
				if (!skip && exprResult) {
					skip = true;
					matches = true;
				}
			}
		}
		
		return matches;	
	}
	
	/** Returns `true` if all tags in the continer matche all expressions the query
	 * @ignore
	 * @arg {Struct.TagContainer} tags The tags to evaluate against this query
	 * @arg {Bool} skip True if this evaluation should not be executed
	 * @return {Bool} */	
	static EvaluateAllExprMatch = function(tags, skip) {
		//Assume true until proven otherwise
		var matches = true;
		
		//Parse tags
		var numExpr = Next();
		if (!readError) {
			
			//Loop through tags until we find 1 match
			for (var i = 0, tagIndex, exprResult; i < numExpr; i++) {
				//Each expression MUST be evaluated then checked. Trying to do them in the same if statement as skip can result in the evaluation not triggering properly.
				exprResult = EvaluateInternal(tags, skip);
				if (!skip && !exprResult) {
					skip = true;
					matches = false;
				}
			}
		}
		
		return matches;		
	}
	
	/** Returns `true` if no tags from the continer match the expressions in the query
	 * @ignore
	 * @arg {Struct.TagContainer} tags The tags to evaluate against this query
	 * @arg {Bool} skip True if this evaluation should not be executed
	 * @return {Bool} */	
	static EvaluateNoExprMatch = function(tags, skip) {
		//Assume true until proven otherwise
		var matches = true;
		
		//Parse tags
		var numExpr = Next();
		if (!readError) {
			
			//Loop through tags until we find 1 match
			for (var i = 0, tagIndex, exprResult; i < numExpr; i++) {
				//Each expression MUST be evaluated then checked. Trying to do them in the same if statement as skip can result in the evaluation not triggering properly.
				exprResult = EvaluateInternal(tags, skip);
				if (!skip && exprResult) {
					skip = true;
					matches = false;
				}
			}
		}
		
		return matches;			
	}
}