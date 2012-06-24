/*********************************************************************************
 
 © Copyright 2009-2012, Isaac Greenspan
 
 Permission is hereby granted, free of charge, to any person
 obtaining a copy of this software and associated documentation
 files (the "Software"), to deal in the Software without
 restriction, including without limitation the rights to use,
 copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the
 Software is furnished to do so, subject to the following
 conditions:
 
 The above copyright notice and this permission notice shall be
 included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 OTHER DEALINGS IN THE SOFTWARE.
 
 *********************************************************************************/

/*
 *  LJErrors.h
 *  asLJCore
 *
 *  Created by Isaac Greenspan on 8/2/09.
 *
 */

#define asLJCore_ErrorDomain @"us.2718.asLJCore.ErrorDomain"
#define asLJCore_LJErrorDomain @"us.2718.asLJCore.LJ.ErrorDomain"


// based on http://code.livejournal.org/trac/livejournal/browser/trunk/cgi-bin/ljprotocol.pl?rev=15527

// === user errors ===

#define LJInvalidUsernameErrorCode 100
#define LJInvalidUsernameErrorDescription @"Invalid username"

#define LJInvalidPasswordErrorCode 101
#define LJInvalidPasswordErrorDescription @"Invalid password"

#define LJCustomPrivateSecurityOnCommunitiesErrorCode 102
#define LJCustomPrivateSecurityOnCommunitiesErrorDescription @"Can't use custom/private security on shared/community journals."

#define LJPollErrorCode 103
#define LJPollErrorDescription @"Poll error"

#define LJAddingFriendsErrorCode 104
#define LJAddingFriendsErrorDescription @"Error adding one or more friends"

#define LJChallengeExpiredErrorCode 105
#define LJChallengeExpiredErrorDescription @"Challenge expired"

#define LJPostAsNonUserErrorCode 150
#define LJPostAsNonUserErrorDescription @"Can't post as non-user"

#define LJBannedErrorCode 151
#define LJBannedErrorDescription @"Banned from journal"

#define LJBackdateNonpersonalErrorCode 152
#define LJBackdateNonpersonalErrorDescription @"Can't make back-dated entries in non-personal journal."

#define LJTimeValueErrorCode 153
#define LJTimeValueErrorDescription @"Incorrect time value"

#define LJAddRedirectedFriendErrorCode 154
#define LJAddRedirectedFriendErrorDescription @"Can't add a redirected account as a friend"

#define LJEmailAddressAuthenticationErrorCode 155
#define LJEmailAddressAuthenticationErrorDescription @"Non-authenticated email address"

#define LJTOSErrorCode 156   // not sure about this one--it wasn't clear in the LJ code
#define LJTOSErrorDescription @"ToS approval needed"

#define LJTagsErrorCode 157
#define LJTagsErrorDescription @"Tags error"


// === client errors ===

#define LJMissingRequiredArgumentsErrorCode 200
#define LJMissingRequiredArgumentsErrorDescription @"Missing required argument(s)"

#define LJUnknownMethodErrorCode 201
#define LJUnknownMethodErrorDescription @"Unknown method"

#define LJTooManyArgumentsErrorCode 202
#define LJTooManyArgumentsErrorDescription @"Too many arguments"

#define LJInvalidArgumentsErrorCode 203
#define LJInvalidArgumentsErrorDescription @"Invalid argument(s)"

#define LJInvalidMetadataDatatypeErrorCode 204
#define LJInvalidMetadataDatatypeErrorDescription @"Invalid metadata datatype"

#define LJUnknownMetadataErrorCode 205
#define LJUnknownMetadataErrorDescription @"Unknown metadata"

#define LJInvalidDestinationJournalErrorCode 206
#define LJInvalidDestinationJournalErrorDescription @"Invalid destination journal username."

#define LJProtocolVersionMismatchErrorCode 207
#define LJProtocolVersionMismatchErrorDescription @"Protocol version mismatch"

#define LJInvalidTextEncodingErrorCode 208
#define LJInvalidTextEncodingErrorDescription @"Invalid text encoding"

#define LJParameterOutOfRangeErrorCode 209
#define LJParameterOutOfRangeErrorDescription @"Parameter out of range"

#define LJEditWithCorruptDataErrorCode 210
#define LJEditWithCorruptDataErrorDescription @"Client tried to edit with corrupt data.  Preventing."

#define LJInvalidTagListErrorCode 211
#define LJInvalidTagListErrorDescription @"Invalid or malformed tag list"

#define LJBodyTooLongErrorCode 212
#define LJBodyTooLongErrorDescription @"Message body is too long"

#define LJBodyEmptyErrorCode 213
#define LJBodyEmptyErrorDescription @"Message body is empty"

#define LJLooksLikeSpamErrorCode 214
#define LJLooksLikeSpamErrorDescription @"Message looks like spam"


// === access errors ===

#define LJJournalAccessErrorCode 300
#define LJJournalAccessErrorDescription @"Don't have access to requested journal"

#define LJRestrictedFeatureErrorCode 301
#define LJRestrictedFeatureErrorDescription @"Access of restricted feature"

#define LJCantEditJournalErrorCode 302
#define LJCantEditJournalErrorDescription @"Can't edit post from requested journal"

#define LJCantEditCommunityErrorCode 303
#define LJCantEditCommunityErrorDescription @"Can't edit post in community journal"

#define LJCantDeleteCommunityErrorCode 304
#define LJCantDeleteCommunityErrorDescription @"Can't delete post in this community journal"

#define LJAccountSuspendedErrorCode 305
#define LJAccountSuspendedErrorDescription @"Action forbidden; account is suspended."

#define LJReadOnlyModeErrorCode 306
#define LJReadOnlyModeErrorDescription @"This journal is temporarily in read-only mode.  Try again in a couple minutes."

#define LJJournalDoesntExistErrorCode 307
#define LJJournalDoesntExistErrorDescription @"Selected journal no longer exists."

#define LJAccountLockedErrorCode 308
#define LJAccountLockedErrorDescription @"Account is locked and cannot be used."

#define LJAccountMemorialErrorCode 309
#define LJAccountMemorialErrorDescription @"Account is marked as a memorial."

#define LJNeedAgeVerifiedErrorCode 310
#define LJNeedAgeVerifiedErrorDescription @"Account needs to be age verified before use."

#define LJAccessDisabledErrorCode 311
#define LJAccessDisabledErrorDescription @"Access temporarily disabled."

#define LJCantAddTagsToEntriesErrorCode 312
#define LJCantAddTagsToEntriesErrorDescription @"Not allowed to add tags to entries in this journal"

#define LJUseExistingTagsErrorCode 313
#define LJUseExistingTagsErrorDescription @"Must use existing tags for entries in this journal (can't create new ones)"

#define LJPaidOnlyErrorCode 314
#define LJPaidOnlyErrorDescription @"Only paid users allowed to use this request"

#define LJMessagingDisabledErrorCode 315
#define LJMessagingDisabledErrorDescription @"User messaging is currently disabled"

#define LJPostPosterReadOnlyErrorCode 316
#define LJPostPosterReadOnlyErrorDescription @"Poster is read-only and cannot post entries."

#define LJPostJournalReadOnlyErrorCode 317
#define LJPostJournalReadOnlyErrorDescription @"Journal is read-only and entries cannot be posted to it."

#define LJEditPosterReadOnlyErrorCode 318
#define LJEditPosterReadOnlyErrorDescription @"Poster is read-only and cannot edit entries."

#define LJEditJournalReadOnlyErrorCode 319
#define LJEditJournalReadOnlyErrorDescription @"Journal is read-only and its entries cannot be edited."


// === limit errors ===

#define LJIPBanFailedLoginsErrorCode 402
#define LJIPBanFailedLoginsErrorDescription @"Your IP address is temporarily banned for exceeding the login failure rate."

#define LJCannotPostErrorCode 404
#define LJCannotPostErrorDescription @"Cannot post"

#define LJPostFrequencyLimitErrorCode 405
#define LJPostFrequencyLimitErrorDescription @"Post frequency limit."

#define LJClientRepeatingBrokenErrorCode 406
#define LJClientRepeatingBrokenErrorDescription @"Client is making repeated requests.  Perhaps it's broken?"

#define LJModQFullErrorCode 407
#define LJModQFullErrorDescription @"Moderation queue full"

#define LJCommPosterQFullErrorCode 408
#define LJCommPosterQFullErrorDescription @"Maximum queued posts for this community+poster combination reached."

#define LJPostTooLargeErrorCode 409
#define LJPostTooLargeErrorDescription @"Post too large."

#define LJTrialExpiredErrorCode 410
#define LJTrialExpiredErrorDescription @"Your trial account has expired.  Posting now disabled."

#define LJActionFrequencyLimitErrorCode 411
#define LJActionFrequencyLimitErrorDescription @"Action frequency limit."


// === server errors ===

#define LJInternalServerErrorCode 500
#define LJInternalServerErrorDescription @"Internal server error"

#define LJDatabaseErrorCode 501
#define LJDatabaseErrorDescription @"Database error"

#define LJDatabaseUnavailableErrorCode 502
#define LJDatabaseUnavailableErrorDescription @"Database temporarily unavailable"

#define LJDatabaseLockErrorCode 503
#define LJDatabaseLockErrorDescription @"Error obtaining necessary database lock"

#define LJProtocolModeUnsupportedErrorCode 504
#define LJProtocolModeUnsupportedErrorDescription @"Protocol mode no longer supported."

#define LJOldFormatErrorCode 505
#define LJOldFormatErrorDescription @"Account data format on server is old and needs to be upgraded."

#define LJSyncUnavailableErrorCode 506
#define LJSyncUnavailableErrorDescription @"Journal sync temporarily unavailable."


