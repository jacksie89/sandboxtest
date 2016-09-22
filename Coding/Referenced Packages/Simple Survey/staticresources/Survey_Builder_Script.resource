/*
03/25/16 BS Unescape XML character entities in all metadata operations,
            allow mapping a text field from the survey object to a Text Area or Long Text Area on Survey,
            prevent clicking on an uncompleted step from redirecting to the Choose Survey step in some cases,
            attempting to add a question that already exists will no longer display the error alert underneath the new question dialog (128683)
03/28/16 BS Added check for existing field set,
            do not attempt to add questions to the Custom Links section when that section is first on the layout,
            perform initial survey metadata creation in parallel,
            improve reliability of adding questions to page layouts (128683)
04/14/16 BS Pick list values with special characters will no longer cause save error (128683)
04/20/16 BS Send email for external marketing tool (130080)
05/19/16 BS Standard Survey fields and related lists will be added to new Survey layouts,
            configure Survey Object step will now add mapped fields to the layout (131507)
05/24/16 MD Add custom subject field (131504)
05/27/16 BS Survey Record Ownership (131508)
06/01/16 MD Add support for custom background colors/images on landing page & email template (131505)
06/07/16 BS Fix for Summer 16 tooling API chenge (132338)
07/26/16 BS Remove hard coded package namespace references (133595)
08/01/16 BS Pre-merge survey site URL when creating templates for external systems (133619)
*/

"use strict";

// --( Survey Builder Application )--
var SurveyBuilder = angular.module('SurveyBuilder', ['ngRoute','color.picker']);


// --( Route Configuration )--
SurveyBuilder.config(['$routeProvider', function($routeProvider) {
    $routeProvider.
        when('/ChooseSurvey', {
            templateUrl: SURVEY_BUILDER + '?step=choose_survey',
            controller: 'ChooseSurveyController'
        }).
        when('/ChooseSurvey/:id', {
            templateUrl: function(params) { return SURVEY_BUILDER + '?id=' + params.id + '&step=choose_survey' },
            controller: 'ChooseSurveyController'
        }).
        when('/ConfigureSurveyObject/:id', {
            templateUrl:  function(params) { return SURVEY_BUILDER + '?id=' + params.id + '&step=configure_survey_object' },
            controller: 'ConfigureSurveyObjectController'
        }).
        when('/AddQuestions/:id', {
            templateUrl:  function(params) { return SURVEY_BUILDER + '?id=' + params.id + '&step=add_questions' },
            controller: 'AddQuestionsController'
        }).
        when('/CreateEmailTemplate/:id', {
            templateUrl:  function(params) { return SURVEY_BUILDER + '?id=' + params.id + '&step=create_email_template' },
            controller: 'CreateEmailTemplateController'
        }).
        otherwise({
            redirectTo: '/ChooseSurvey',
        });
}]);


// --( Controller for Choose Survey Step )--
SurveyBuilder.controller('ChooseSurveyController', ['$scope', '$q', 'ctrl', 'util', function($scope, $q, ctrl, util) {
    $scope.processing = false;
    $scope.processingLabel = '';
    $scope.option = SITE_CONFIGURED ? (HAVE_CUSTOMIZE_APPLICATION ? 'create_new' : 'edit_existing') : 'configure_site';
    $scope.ratingScale = '0-10';
    $scope.display = 'active';
    $scope.existingSurveys = [];
    $scope.selectedSurvey = null;
    $scope.surveyName = '';
    $scope.nameRequired = false;
    $scope.nameDuplicate = false;
    $scope.surveyRequired = false;
    $scope.haveCustomizeApplication = HAVE_CUSTOMIZE_APPLICATION;

    function uniqueName() {
        for(var i = 0; i < $scope.existingSurveys.length; i++)
            if($scope.surveyName.toLowerCase() == $scope.existingSurveys[i].Name.toLowerCase())
                return false;
        return true;
    }

    $scope.markActive = function(active, proceedToConfigure) {
        if($scope.selectedSurvey == null) {
            $scope.surveyRequired = true;
            return;
        }
        $scope.surveyRequired = false;

        $scope.selectedSurvey[PKG_NS_PREFIX + 'Inactive__c'] = !active;
        var config = {Id: $scope.selectedSurvey.Id};
        config[PKG_NS_PREFIX + 'Inactive__c'] = !active;

        var promise = ctrl.saveConfiguration(config).then(function() {
            if(proceedToConfigure == true)
                $scope.configureSurveyObject();
        });

        if(proceedToConfigure != true)
            $scope.selectedSurvey = null;
    }

    $scope.showSurvey = function(config) {
        return config[PKG_NS_PREFIX + 'Inactive__c'] != ($scope.display == 'active');
    }

    $scope.doNavigate = function(path) {
        if(path != '' && path.indexOf('ChooseSurvey') == -1)
            location.assign(path);
    }

    $scope.proceed = function() {
        if($scope.selectedSurvey == null) {
            $scope.surveyRequired = true;
            return;
        }
        $scope.surveyRequired = false;

        if($scope.display == 'active')
            $scope.configureSurveyObject();
        else
            $scope.showActivationPrompt = true;
    }

    $scope.configureSurveyObject = function() {
        if($scope.haveCustomizeApplication)
            location.href = '#/ConfigureSurveyObject/' + $scope.selectedSurvey.Id;
        else
            location.href = '#/CreateEmailTemplate/' + $scope.selectedSurvey.Id;
    }

    $scope.createSurvey = function() {
        $scope.nameRequired = false;
        $scope.nameDuplicate = false;

        if($scope.surveyName == null || $scope.surveyName.trim() == '') {
            $scope.nameRequired = true;
            return;
        }
        $scope.surveyName = $scope.surveyName.trim();

        if(!uniqueName()) {
            $scope.nameDuplicate = true;
            return;
        }

        var apiName = util.generateName($scope.surveyName);

        $scope.processing = true;
        $scope.processingLabel = 'Creating Record Type...';

        //Create metadata then insert setting and redirect
        ctrl.checkFieldsetExists(apiName).then(function(fieldsetExists) {
            if(!fieldsetExists) {
                $scope.processingLabel = 'Creating Page Layout and Field Set...';
                util.createSurveyRecordType(apiName, $scope.surveyName).then(function() {
                    $q.all({
                        layout: util.createSurveyLayout($scope.surveyName, $scope.ratingScale != 'None'),
                        fieldSet: util.createSurveyFieldSet(apiName, $scope.surveyName)
                    }).then(function(asyncResults) {
                        ctrl.getSurveyRecordTypeIdByDeveloperName(apiName).then(function(recordTypeId) {
                            $scope.processingLabel = 'Updating Layout Assignment...';
                            util.assignLayout($scope.surveyName, apiName).then(function(result) {
                                $scope.processingLabel = 'Saving Configuration...';

                                var config = {Name: $scope.surveyName};
                                config[PKG_NS_PREFIX + 'Rating_Scale__c'] = $scope.ratingScale;
                                config[PKG_NS_PREFIX + 'Layout__c'] = asyncResults.layout.fullName;
                                config[PKG_NS_PREFIX + 'Record_Type__c'] = recordTypeId;
                                config[PKG_NS_PREFIX + 'Field_Set__c'] = asyncResults.fieldSet.fullName;
                                config[PKG_NS_PREFIX + 'Last_Step_Completed__c'] = 'Choose Survey';
                                config[PKG_NS_PREFIX + 'New_Template_Needed__c'] = true;

                                ctrl.saveConfiguration(config).then(function(recordId) {
                                    location.href = '#/ConfigureSurveyObject/' + recordId;
                                });

                            }).catch(showError);
                        });
                    }).catch(showError);
                }).catch(showError);
            }
            else {
                $scope.processing = false;
                $scope.alertType = 'error';
                $scope.alertTitle = 'Error';
                $scope.alertMessage = 'A Survey field set for ' + $scope.surveyName + ' already exists. Enter a different name.';
                $scope.alertShow = true;
            }
        });

        function showError(reason) {
            $scope.processing = false;
            $scope.alertType = 'error';
            $scope.alertTitle = 'Error';
            $scope.alertMessage = util.extractErrors(reason);
            $scope.alertShow = true;
        }
    }

    ctrl.getSurveyConfigurations().then(function(result) { $scope.existingSurveys = result; });
}]);


// --( Controller for Configure Survey Object Step )--
SurveyBuilder.controller('ConfigureSurveyObjectController', ['$scope', '$routeParams', '$q', 'ctrl', 'util', function($scope, $routeParams, $q, ctrl, util) {
    var navigationPath;
    var loading = true;
    $scope.showAllFialds = false;
    $scope.surveyObjectFields = [];
    $scope.surveyFromObjectOptions = [{value: 'Case', label: 'Case (Case)'}];
    $scope.surveyFromObject = $scope.surveyFromObjectOptions[0];
    $scope.surveyFromObjectFields = [];
    $scope.lastStepCompleted = 'Choose Survey';
    $scope.ownerAssignment = 'none';
    $scope.ownerAssignmentId = '';
    $scope.ownerAssignmentName = '';
    $scope.ownerAssignmentOptions = [];

    $scope.$watch('ownerAssignmentName', function() {
        if($scope.ownerAssignmentName !== undefined) {
            ctrl.lookupUsers($scope.ownerAssignmentName).then(function(userOptions) {
                $scope.ownerAssignmentOptions = [];

                if(userOptions != null)
                    $scope.ownerAssignmentOptions = userOptions;
            });
        }
    });

    //To detect changes / if the email template needs to be updated
    var oldSurveyObject = null;
    var oldFieldMapping = null;

    $scope.doNavigate = function(path) {
        if(path != '' && document.querySelector('.ng-dirty') == null)
            location.assign(path);
        else if(path != '' && path.indexOf('ConfigureSurveyObject') == -1) {
            navigationPath = path;
            $scope.showNavigationConfirmation = true;
        }
    };

    $scope.proceedNavigation = function() {
        location.assign(navigationPath);
    }

    $scope.saveProceedNavigation = function() {
        $scope.save(true).then(function() {
            location.assign(navigationPath);
        }).catch(function() {
            $scope.alertType = 'error';
            $scope.alertTitle = 'Aborted';
            $scope.alertMessage = 'An error occurred while the saving survey configuration';
            $scope.alertShow = true;
            $scope.showNavigationConfirmation = false;
        });
    }

    //Populate fieldOptions on surveyObjectFields with surveyFromObjectFields that can be selected and set fieldSelected to defaults
    function updateFieldMapping(assignment) {
        $scope.surveyObjectFields.forEach(function(surveyField) {
            updateFieldMappingForField(surveyField, assignment);
        });
    }

    function updateFieldMappingForField(dest, assignment) {
        dest.fieldOptions = [{value: '__NONE__', label: '--None--'}];
        dest.fieldSelected = dest.fieldOptions[0];

        $scope.surveyFromObjectFields.forEach(function(src) {
            /*
            This is a little complex, okay here we go...
            If types match and are not reference fields
            Or types match and reference fields are of same type
            Or types match and destination field is Record Owner (User Id) and source field is Owner Id (Polymorphic Id)
            Or types do not match and destination is of type REFERENCE and source is of type ID and destination referenceTo is the source object
            Or types do not match and destination is of type TEXTAREA and source is of type STRING
            */
            if((dest.type == src.type && (src.type != 'REFERENCE' || dest.referenceTo[0] == src.referenceTo[0] || (dest.value == (PKG_NS_PREFIX + 'Record_Owner__c') && src.value == 'OwnerId'))) || (dest.type == 'REFERENCE' && src.type == 'ID' && dest.referenceTo[0] == $scope.surveyFromObject.value) || (dest.type == 'TEXTAREA' && src.type == 'STRING')) {
                dest.fieldOptions.push(src);

                //Use saved assignment
                if(assignment != null && dest.value in assignment && assignment[dest.value].type == 'field' && src.value == assignment[dest.value].value)
                    dest.fieldSelected = src;
                //Auto assign if no saved assignment and labels match
                else if(assignment == null && (dest.label == src.label.replace(/ ID$/, '') || (dest.value == (PKG_NS_PREFIX + 'Record_Owner__c') && src.value == 'OwnerId') || (dest.type == 'REFERENCE' && src.type == 'ID' && dest.referenceTo[0] == $scope.surveyFromObject.value)))
                    dest.fieldSelected = src;
            }
        });

        dest.fieldOptions.push({value: '__VALUE__', label: '(Fixed Value)'});

        //Default to first option if exists
        if(dest.fieldSelected == null && dest.fieldOptions.length > 2)
            dest.fieldSelected = dest.fieldOptions[1];

        //Use saved static value
        if(assignment != null && dest.value in assignment && assignment[dest.value].type == 'value') {
            dest.fieldSelected = dest.fieldOptions[dest.fieldOptions.length - 1]; //Fixed Value
            dest.staticValue = assignment[dest.value].value;
        }
    }

    $scope.surveyFromObjectChanged = function() {
        ctrl.getSurveyFromObjectFields($scope.surveyFromObject.value).then(function(result) {
            $scope.surveyFromObjectFields = result;
            updateFieldMapping(null);
        });
    }

    $scope.getFromObjectName = function() {
        var label = $scope.surveyFromObject.label;
        return label.substring(0, label.indexOf(' ('));
    }

    $scope.getFilterReferenceFields = function() {
        return $scope.showAllFialds ? '' : 'REFERENCE';
    }

    $scope.save = function(quiteOpt) {
        var fieldMapping = {};
        $scope.surveyObjectFields.forEach(function(dest) {
            if(dest.fieldSelected.value != '__NONE__' && dest.fieldSelected.value != '__VALUE__') {
                fieldMapping[dest.value] = {
                    type: 'field',
                    value: dest.fieldSelected.value
                }
            }
            else if(dest.fieldSelected.value == '__VALUE__') {
                fieldMapping[dest.value] = {
                    type: 'value',
                    value: dest.staticValue
                }
            }
        });

        var config = {Id: $routeParams.id};
        config[PKG_NS_PREFIX + 'Survey_Object__c'] = $scope.surveyFromObject.value;
        config[PKG_NS_PREFIX + 'Survey_Object_Field_Assignment__c'] = JSON.stringify(fieldMapping, null, '  ');

        if(config[PKG_NS_PREFIX + 'Survey_Object__c'] != oldSurveyObject || config[PKG_NS_PREFIX + 'Survey_Object_Field_Assignment__c'] != oldFieldMapping)
            config[PKG_NS_PREFIX + 'New_Template_Needed__c'] = true;

        if($scope.lastStepCompleted == 'Choose Survey')
            config[PKG_NS_PREFIX + 'Last_Step_Completed__c'] = 'Configure Survey Object';

        config[PKG_NS_PREFIX + 'Owner_Assignment__c'] = $scope.ownerAssignment != 'none' ? $scope.ownerAssignment : '';
        config[PKG_NS_PREFIX + 'Owner_Assignment_Id__c'] = $scope.ownerAssignmentId != null ? $scope.ownerAssignmentId : '';

        return $q(function(resolve, reject) {
            $scope.userRequired = false;
            if($scope.ownerAssignment == 'id' && $scope.ownerAssignmentId == null || $scope.ownerAssignmentId == '') {
                $scope.userRequired = true;
                reject('User Required');
                return;
            }

            var fields = Object.keys(fieldMapping);
            util.addFieldsToLayout($scope.layoutName, fields, true, 'Survey Information').then(function() {
                ctrl.saveConfiguration(config).then(function(result) {
                    if(result == null)
                        error();
                    else {
                        if($scope.lastStepCompleted == 'Choose Survey')
                            $scope.lastStepCompleted = 'Configure Survey Object';

                        if(quiteOpt != true) {
                            $scope.alertType = 'info';
                            $scope.alertTitle = 'Configuration Saved';
                            $scope.alertMessage = 'Configuration has been successfully saved';
                            $scope.alertShow = true;
                        }
                        util.removeDirtyFlag();
                        resolve('success');
                    }
                });
            }).catch(error);

            function error() {
                if(quiteOpt != true) {
                    $scope.alertType = 'error';
                    $scope.alertTitle = 'Error';
                    $scope.alertMessage = 'An error occurred while the saving survey configuration';
                    $scope.alertShow = true;
                }
                reject('error occurred');
            }
        });
    }

    $scope.saveContinue = function() {
        $scope.save(true).then(function() {
            location.href = '#/AddQuestions/' + $routeParams.id;
        }).catch(function() {
            $scope.alertType = 'error';
            $scope.alertTitle = 'Aborted';
            $scope.alertMessage = 'An error occurred while the saving survey configuration';
            $scope.alertShow = true;
        });
    }

    $scope.haveSurveyObjectLookup = function() {
        if(loading) return true;

        var haveReference = false;
        $scope.surveyObjectFields.forEach(function(field) {
            if(field.type == 'REFERENCE' && field.referenceTo[0] == $scope.surveyFromObject.value)
                haveReference = true;
        });
        return haveReference;
    }

    $scope.createSurveyObjectLookup = function() {
        var label = $scope.getFromObjectName();
        var name = util.generateName(label) + '__c';
        var referenceTo = $scope.surveyFromObject.value;

        $scope.processing = true;
        $scope.processingLabel = 'Creating Lookup from Survey to ' + label + '...';
        util.createField(name, label, 'Lookup', label + ' associated with the Survey', '', null, null, null, referenceTo).then(function(metadata) {
            //New field to add to the field assignment editor
            var field = {
                value: util.nsPrefix + name,
                label: label,
                type: 'REFERENCE',
                referenceTo: [referenceTo]
            }

            //Find where to insert the new lookup field (lexicographic ordering on field label)
            var l = 0;
            var r = $scope.surveyObjectFields.length - 1;
            var m;
            while(l <= r) {
                m = (l + r) >> 1;
                if(label < $scope.surveyObjectFields[m].label)
                    r = m - 1;
                else
                    l = m + 1;
            }
            $scope.surveyObjectFields.splice(l, 0, field); //Insert new lookup field at 'l'

            //Populate possible field mapping options and default to the Record Id
            updateFieldMappingForField(field, null);

            $scope.processingLabel = 'Updating Field Security (this may take more than one minute)...';
            util.updateFieldSecurity([field.value]).then(function() {
                $scope.processing = false;
            }).catch(showError);
        }).catch(showError);

        function showError(error) {
            $scope.processing = false;
            $scope.alertType = 'error';
            $scope.alertTitle = 'Error';
            $scope.alertMessage = util.extractErrors(error);
            $scope.alertShow = true;
        }
    }

    $scope.processing = true;
    $scope.processingLabel = 'Loading Fields...';
    ctrl.getSurveyObjectConfiguration($routeParams.id).then(function(result) {
        ['surveyObjectFields', 'surveyFromObjectOptions', 'surveyFromObjectFields', 'lastStepCompleted', 'layoutName', 'ownerAssignment', 'ownerAssignmentId', 'ownerAssignmentName'].forEach(function(property) {
            $scope[property] = result[property];
        });

        if($scope.ownerAssignment == undefined)
            $scope.ownerAssignment = 'none';

        //Set $scope.surveyFromObject to the correct option object
        $scope.surveyFromObjectOptions.forEach(function(option) {
            if(('surveyFromObject' in result && option.value == result.surveyFromObject) || (!('surveyFromObject' in result) && option.value == 'Case'))
                $scope.surveyFromObject = option;
        });
        if('surveyFromObject' in result)
            oldSurveyObject = result.surveyFromObject;

        var assignment = null;
        if('fieldAssignment' in result) {
            assignment = JSON.parse(result.fieldAssignment);
            oldFieldMapping = result.fieldAssignment.replace(/\r/g, '');
        }

        updateFieldMapping(assignment);
        loading = false;
        $scope.processing = false;
    });
}]);


// --( Controller for Add Questions Step )--
SurveyBuilder.controller('AddQuestionsController', ['$scope', '$routeParams', '$q', 'ctrl', 'util', function($scope, $routeParams, $q, ctrl, util) {
    var navigationPath;
    var fieldSet;
    var layoutName;
    var questionsDirty = false;
    $scope.picklistDisplay = 'Standard';
    $scope.multiPicklistDisplay = 'Standard';
    $scope.processing = true;
    $scope.processingLabel = 'Loading Questions...';
    $scope.availableFields = [];
    $scope.selectedFields = [];
    $scope.surveyRecordTypeId = null;
    $scope.addingQuestion = false;
    $scope.confirmAndNavigate = util.confirmAndNavigate;
    $scope.surveyObjectToolingId = null;
    $scope.surveyFieldToolingIdsByName = {};
    $scope.customizeLandingPage = 'none';
    $scope.customizeEmailTemplate = 'none';
    $scope.landingPageDocument = 'none';
    $scope.landingPageDocumentOptions = [];

    // remove the dirty flag on the color-picker element
    setTimeout(function(){
        // [].forEach.call(document.querySelectorAll('.ng-dirty'), function(el){el.className = el.className.replace('ng-dirty', '');});
        util.removeDirtyFlag();
        var colorInput = document.querySelector('color-picker#landingPageColor input');
        colorInput.placeholder = "#xxxxxx";
    }, 500);
    // }, 500);

    //To detect changes / if the email template needs to be updated
    var oldPicklistDisplay = null;
    var oldMultiselectPicklistDisplay = null;

    $scope.doNavigate = function(path) {
        if(path != '' && document.querySelector('.ng-dirty') == null && questionsDirty == false)
            location.assign(path);
        else if(path != '' && path.indexOf('AddQuestions') == -1) {
            navigationPath = path;
            $scope.showNavigationConfirmation = true;
        }
    };

    $scope.proceedNavigation = function() {
        location.assign(navigationPath);
    }

    $scope.saveProceedNavigation = function() {
        $scope.showNavigationConfirmation = false;

        $scope.save(false).then(function() {
            location.assign(navigationPath);
        }).catch(function() {
            $scope.alertType = 'error';
            $scope.alertTitle = 'Aborted';
            $scope.alertMessage = 'An error occurred while the saving survey configuration';
            $scope.alertShow = true;
        });
    }

    $scope.addQuestion = function() {
        $scope.fieldTypes = [
            {value: 'Checkbox', label: 'Checkbox'},
            {value: 'Currency', label: 'Currency'},
            {value: 'Date', label: 'Date'},
            {value: 'DateTime', label: 'DateTime'},
            {value: 'Email', label: 'Email'},
            {value: 'Number', label: 'Number'},
            {value: 'Percent', label: 'Percent'},
            {value: 'Phone', label: 'Phone'},
            {value: 'Picklist', label: 'Picklist'},
            {value: 'MultiselectPicklist', label: 'Picklist (Multi-Select)'},
            {value: 'Text', label: 'Text'},
            {value: 'TextArea', label: 'Text Area'},
            {value: 'LongTextArea', label: 'Text Area (Long)'}
        ];

        $scope.visibleLinesOptions = [];
        for(var i = 2; i < 51; i++)
            $scope.visibleLinesOptions.push({label: i, value: i});

        $scope.precisionOptions = [];
        for(var i = 0; i < 18; i++)
            $scope.precisionOptions.push({label: i, value: i});

        //Show new question dialog
        $scope.addingQuestion = true;

        $scope.question = '';
        $scope.label = '';
        $scope.fieldType = 'Text';
        $scope.picklistOptions = '';
        $scope.visibleLines = 4;
        $scope.decimalPlaces = 2;

        $scope.required = {
            question: false,
            label: false,
            choices: false
        };
    }

    $scope.cancelAddQuestion = function() {
        $scope.addingQuestion = false;
    }

    $scope.createQuestion = function(andNew) {
        $scope.required.question = false;
        $scope.required.label = false;
        $scope.required.choices = false;

        if($scope.question.trim() == '')
            $scope.required.question = true;
        if($scope.label.trim() == '')
            $scope.required.label = true;
        if(($scope.fieldType == 'Picklist' || $scope.fieldType == 'MultiselectPicklist') && $scope.picklistOptions.trim() == '')
            $scope.required.choices = true;

        if($scope.required.question || $scope.required.label || $scope.required.choices)
            return;

        $scope.addingQuestion = false;
        $scope.processing = true;
        $scope.processingLabel = 'Creating Field...';

        var decimalPlaces = $scope.fieldType == 'Currency' ? 2 : $scope.decimalPlaces;
        util.createField(util.generateName($scope.label) + '__c', $scope.label, $scope.fieldType, 'Question Created by the Survey Builder', $scope.question, $scope.visibleLines, $scope.picklistOptions.split('\n'), decimalPlaces, null).then(function(metadata) {
            metadata.fullName = metadata.fullName.split('.')[1];
            $scope.selectedFields.push(metadata);
            $scope.processing = false;
            if(andNew)
                $scope.addQuestion();

            util.getSurveyToolingIds().then(function(result) {
                $scope.surveyObjectToolingId = result.objectId;
                $scope.surveyFieldToolingIdsByName = result.fieldIdsByName;
            });
        }).catch(function(reason) {
            $scope.processing = false;
            $scope.addingQuestion = false;
            $scope.alertType = 'error';
            $scope.alertTitle = 'Error';
            $scope.alertMessage = util.extractErrors(reason);
            $scope.alertShow = true;
            $scope.alertOkayAction = function() {
                $scope.alertOkayAction = null;
                $scope.addingQuestion = true;
            }
            window.scope = $scope;
        });
    }

    $scope.availableDropHandler = function(dropTarget, question) {
        questionDropped($scope.availableFields, dropTarget, question);
    };

    $scope.selectedDropHandler = function(dropTarget, question) {
        questionDropped($scope.selectedFields, dropTarget, question);
    };

    $scope.availableDropzoneHandler = function(dropTarget, question) {
        purgeQuestion(question);
        $scope.availableFields.push(question);
    };

    $scope.selectedDropzoneHandler = function(dropTarget, question) {
        purgeQuestion(question);
        $scope.selectedFields.push(question);
    };

    function questionDropped(list, dropTarget, question) {
        if(dropTarget.question.fullName == question.fullName)
            return;

        var draggedDown = 0;
        for(var i = 0; i < dropTarget.$index; i++)
            if(list[i].fullName == question.fullName)
                draggedDown = 1;

        purgeQuestion(question);

        for(var i = 0; i < list.length; i++) {
            if(list[i].fullName == dropTarget.question.fullName) {
                list.splice(i + draggedDown, 0, question);
                return;
            }
        }
    }

    $scope.save = function(doContinue) {
        return $q(function(resolve, reject) {
            var surveyFields = [];
            $scope.selectedFields.forEach(function(field) {
                surveyFields.push({
                    field: field.fullName,
                    isFieldManaged: false,
                    isRequired: false
                });
            });

            fieldSet.availableFields = [];
            fieldSet.displayedFields = surveyFields;

            $scope.processing = true;
            $scope.processingLabel = 'Updating Field Set...';
            util.saveFieldSet(fieldSet).then(function() {
                $scope.processingLabel = 'Updating Record Type...';
                util.addPicklistValuesToRecordType($scope.surveyRecordTypeId, $scope.selectedFields).then(function() {

                    $scope.processingLabel = 'Updating Layout...';
                    var fields = surveyFields.reduce(function(acc, item) {
                        return acc.concat(item.field);
                    }, []);

                    util.addFieldsToLayout(util.escapeXMLEntities(layoutName), fields, false, 'Questions').then(function() {
                        $scope.processingLabel = 'Updating Field Security (this may take more than one minute)...';
                        util.updateFieldSecurity(fields).then(function() {
                            var config = {Id: $routeParams.id};
                            config[PKG_NS_PREFIX + 'Last_Step_Completed__c'] = 'Add Questions';
                            config[PKG_NS_PREFIX + 'Picklist_Display__c'] = $scope.picklistDisplay;
                            config[PKG_NS_PREFIX + 'Multiselect_Picklist_Display__c'] = $scope.multiPicklistDisplay;

                            if(config[PKG_NS_PREFIX + 'Picklist_Display__c'] != oldPicklistDisplay || config[PKG_NS_PREFIX + 'Multiselect_Picklist_Display__c'] != oldMultiselectPicklistDisplay)
                                config[PKG_NS_PREFIX + 'New_Template_Needed__c'] = true;

                            // customization
                            config[PKG_NS_PREFIX + 'Customize_Landing_Page__c'] = $scope.customizeLandingPage == 'none' ? '' : $scope.customizeLandingPage;
                            config[PKG_NS_PREFIX + 'Landing_Page_Image__c'] = $scope.landingPageImage;
                            config[PKG_NS_PREFIX + 'Landing_Page_Color__c'] = $scope.landingPageColor;
                            config[PKG_NS_PREFIX + 'Landing_Page_Document__c'] = $scope.landingPageDocument == 'none' ? '' : $scope.landingPageDocument;

                            $scope.processingLabel = 'Saving Configuration...';
                            ctrl.saveConfiguration(config).then(function(result) {
                                $scope.processing = false;

                                if(result == null) {
                                    $scope.alertType = 'error';
                                    $scope.alertTitle = 'Error';
                                    $scope.alertMessage = 'An error occurred while the saving survey configuration';
                                    $scope.alertShow = true;
                                    reject('error saving configuration');
                                }
                                else {
                                    util.removeDirtyFlag();
                                    resolve('success');

                                    if(doContinue)
                                        location.href = '#/CreateEmailTemplate/' + $routeParams.id;
                                }
                            });
                        }).catch(showErrorMessage);
                    }).catch(showErrorMessage);
                }).catch(showErrorMessage);
            }).catch(showErrorMessage);

            function showErrorMessage(err) {
                reject(err);
                console.log(err);
                $scope.alertType = 'error';
                $scope.alertTitle = 'Error';
                $scope.alertMessage = 'An error occurred while the saving the selected questions';
                $scope.alertShow = true;
                $scope.processing = false;
            }
        });
    }

    function purgeQuestion(question) {
        [$scope.availableFields, $scope.selectedFields].forEach(function(list) {
            for(var i = 0; i < list.length; i++)
                if(list[i].fullName == question.fullName)
                    list.splice(i, 1);
        });
    }

    ctrl.getConfiguration($routeParams.id).then(function(config) {
        layoutName = config[PKG_NS_PREFIX + 'Layout__c'];
        var fieldSetName = config[PKG_NS_PREFIX + 'Field_Set__c'].split('.')[1];

        $scope.picklistDisplay = oldPicklistDisplay = config[PKG_NS_PREFIX + 'Picklist_Display__c'];
        $scope.multiPicklistDisplay = oldMultiselectPicklistDisplay = config[PKG_NS_PREFIX + 'Multiselect_Picklist_Display__c'];
        $scope.surveyRecordTypeId = config[PKG_NS_PREFIX + 'Record_Type__c'];

        $scope.customizeLandingPage = config[PKG_NS_PREFIX + 'Customize_Landing_Page__c'];
        $scope.landingPageImage = config[PKG_NS_PREFIX + 'Landing_Page_Image__c'];
        $scope.landingPageColor = config[PKG_NS_PREFIX + 'Landing_Page_Color__c'];
        $scope.customizeEmailTemplate = config[PKG_NS_PREFIX + 'Customize_Email_Template__c'];
        $scope.emailTemplateImage = config[PKG_NS_PREFIX + 'Email_Template_Image__c'];
        $scope.emailTemplateColor = config[PKG_NS_PREFIX + 'Email_Template_Color__c'];
        if($scope.customizeLandingPage == undefined)
            $scope.customizeLandingPage = 'none';
        if($scope.customizeEmailTemplate == undefined)
            $scope.customizeEmailTemplate = 'none';
        $scope.landingPageDocument = config[PKG_NS_PREFIX + 'Landing_Page_Document__c'];
        ctrl.getDocumentImages().then(function(images){
            $scope.landingPageDocumentOptions = images;
        });
        if($scope.landingPageDocument == undefined)
            $scope.landingPageDocument = 'none';

        util.getSurveyMetadata().then(function(metadata) {
            fieldSet = null;
            for(var i = 0; i < metadata.fieldSets.length; i++) {
                if(metadata.fieldSets[i].fullName == fieldSetName) {
                    fieldSet = metadata.fieldSets[i];
                    fieldSet.fullName = PKG_NS_PREFIX + 'Survey__c.' + fieldSet.fullName;
                    break;
                }
            }

            if(fieldSet == null) {
                alert('Field Set ' + fieldSetName + ' was not found');
                location.href = '#/ChooseSurvey';
                return;
            }

            //To track which fields will be displayed
            var displayedFieldNames = {};
            util.asArray(fieldSet.displayedFields).forEach(function(displayed){
                displayedFieldNames[displayed.field] = 1;
            });

            var allowedTypes = {'Checkbox':1, 'Currency':1, 'Date':1, 'DateTime':1, 'Email':1, 'Number':1, 'Percent':1, 'Phone':1, 'Picklist':1, 'MultiselectPicklist':1, 'Text':1, 'TextArea':1, 'LongTextArea':1};
            var blackList = {};
            blackList[PKG_NS_PREFIX + 'Rating_Scale__c'] = 1;
            var fields = metadata.fields;
            var selectedFieldsByName = {}; //Selected fields are added to this map since they will be out of order relative to the field set
            for(var i in fields) {
                if((fields[i].type in allowedTypes) && !(fields[i].fullName in blackList) && ('inlineHelpText' in fields[i])) {
                    if(fields[i].fullName in displayedFieldNames)
                        selectedFieldsByName[fields[i].fullName] = fields[i];
                    else
                        $scope.availableFields.push(fields[i]);
                }
            }

            //Populate selected fields in the order defined by the field set
            util.asArray(fieldSet.displayedFields).forEach(function(displayed){
                $scope.selectedFields.push(selectedFieldsByName[displayed.field]);
            });

            var initialLoad = true;
            $scope.$watchGroup(['availableFields.length', 'selectedFields.length'], function() {
                if(initialLoad != true)
                    questionsDirty = true;
                initialLoad = false;
            });

            $scope.processing = false;

            util.getSurveyToolingIds().then(function(result) {
                $scope.surveyObjectToolingId = result.objectId;
                $scope.surveyFieldToolingIdsByName = result.fieldIdsByName;
            });
        }).catch(function(){
            console.log('An error occurred while reading survey metadata');
        });
    });
}]);


// --( Controller for Create Email Template Step )--
SurveyBuilder.controller('CreateEmailTemplateController', ['$scope', '$routeParams', 'ctrl', 'util', function($scope, $routeParams, ctrl, util) {
    var settings;
    var config;
    $scope.template = '';
    $scope.language = 'en_US';
    $scope.languageOptions = [{value: "sq", label: "Albanian: sq"}, {value: "ar", label: "Arabic: ar"}, {value: "hy", label: "Armenian: hy"}, {value: "eu", label: "Basque: eu"}, {value: "bs", label: "Bosnian: bs"}, {value: "bn", label: "Bengali: bn"}, {value: "bg", label: "Bulgarian: bg"}, {value: "zh_CN", label: "Chinese (Simplified): zh_CN"}, {value: "zh_TW", label: "Chinese (Traditional): zh_TW"}, {value: "hr", label: "Croatian: hr"}, {value: "cs", label: "Czech: cs"}, {value: "da", label: "Danish: da"}, {value: "nl_NL", label: "Dutch: nl_NL"}, {value: "en_US", label: "English: en_US"}, {value: "en_AU", label: "English (Australia): en_AU"}, {value: "en_CA", label: "English (Canada): en_CA"}, {value: "en_IN", label: "English (India): en_IN"}, {value: "en_MY", label: "English (Malaysia): en_MY"}, {value: "en_PH", label: "English (Philippines): en_PH"}, {value: "en_GB", label: "English (UK): en_GB"}, {value: "et", label: "Estonian: et"}, {value: "fi", label: "Finnish: fi"}, {value: "fr", label: "French: fr"}, {value: "fr_CA", label: "French (Canada): fr_CA"}, {value: "de", label: "German: de"}, {value: "de_AT", label: "German (Austria): de_AT"}, {value: "de_CH", label: "German (Switzerland): de_CH"}, {value: "ka", label: "Georgian: ka"}, {value: "el", label: "Greek: el"}, {value: "iw", label: "Hebrew: iw"}, {value: "hi", label: "Hindi: hi"}, {value: "hu", label: "Hungarian: hu"}, {value: "is", label: "Icelandic: is"}, {value: "in", label: "Indonesian: in"}, {value: "ga", label: "Irish: ga"}, {value: "it", label: "Italian: it"}, {value: "ja", label: "Japanese: ja"}, {value: "ko", label: "Korean: ko"}, {value: "lv", label: "Latvian: lv"}, {value: "lt", label: "Lithuanian: lt"}, {value: "lb", label: "Luxembourgish: lb"}, {value: "mk", label: "Macedonian: mk"}, {value: "ms", label: "Malay: ms"}, {value: "mt", label: "Maltese: mt"}, {value: "sh_ME", label: "Montenegrin: sh_ME"}, {value: "no", label: "Norwegian: no"}, {value: "pl", label: "Polish: pl"}, {value: "pt_BR", label: "Portuguese (Brazil): pt_BR"}, {value: "pt_PT", label: "Portuguese (European): pt_PT"}, {value: "ro", label: "Romanian: ro"}, {value: "ro_MD", label: "Romanian (Moldova): ro_MD"}, {value: "rm", label: "Romansh: rm"}, {value: "ru", label: "Russian: ru"}, {value: "es", label: "Spanish: es"}, {value: "es_MX", label: "Spanish (Mexico): es_MX"}, {value: "sv", label: "Swedish: sv"}, {value: "sr", label: "Serbian (Cyrillic): sr"}, {value: "sh", label: "Serbian (Latin): sh"}, {value: "sk", label: "Slovak: sk"}, {value: "sl", label: "Slovenian: sl"}, {value: "tl", label: "Tagalog: tl"}, {value: "ta", label: "Tamil: ta"}, {value: "th", label: "Thai: th"}, {value: "tr", label: "Turkish: tr"}, {value: "uk", label: "Ukrainian: uk"}, {value: "ur", label: "Urdu: ur"}, {value: "vi", label: "Vietnamese: vi"}, {value: "cy", label: "Welsh: cy"}];
    $scope.nameRequired = false;
    $scope.subjectRequired = false;
    $scope.name = '';
    $scope.description = '';
    $scope.folderOptions = [];
    $scope.folderId = '';
    $scope.subject = '';
    $scope.greeting = '';
    $scope.closing = '';
    $scope.objectOptions = [];
    $scope.selectedObjectGreeting = null;
    $scope.selectedObjectClosing = null;
    $scope.selectedObjectSubject = null;
    $scope.selectedFieldGreeting = null;
    $scope.selectedFieldClosing = null;
    $scope.selectedFieldSubject = null;
    $scope.haveCustomizeApplication = HAVE_CUSTOMIZE_APPLICATION;
    $scope.isFirstEmailTemplate = true;
    $scope.customizeLandingPage = 'none';
    $scope.customizeEmailTemplate = 'none';
    $scope.emailTemplateDocument = 'none';
    $scope.emailTemplateDocumentOptions = [];
    $scope.baseImgUrl = '';

    // remove the dirty flag on the color-picker element
    setTimeout(function(){
        // [].forEach.call(document.querySelectorAll('.ng-dirty'), function(el){el.className = el.className.replace('ng-dirty', '');});
        util.removeDirtyFlag();
        var colorInput = document.querySelector('color-picker#emailTemplateColor input');
        colorInput.placeholder = "#xxxxxx";
    }, 500);

    $scope.doNavigate = function(path) {
        if(path != '' && path.indexOf('CreateEmailTemplate') == -1) {
            config[PKG_NS_PREFIX + 'Last_Email_Template_Greeting__c'] = $scope.greeting;
            config[PKG_NS_PREFIX + 'Last_Email_Template_Closing__c'] = $scope.closing;
            config[PKG_NS_PREFIX + 'Customize_Email_Template__c'] = $scope.customizeEmailTemplate == 'none' ? '' : $scope.customizeEmailTemplate;
            config[PKG_NS_PREFIX + 'Email_Template_Image__c'] = $scope.emailTemplateImage;
            config[PKG_NS_PREFIX + 'Email_Template_Color__c'] = $scope.emailTemplateColor;
            config[PKG_NS_PREFIX + 'Email_Template_Document__c'] = $scope.emailTemplateDocument == 'none' ? '' : $scope.emailTemplateDocument;
            ctrl.saveConfiguration(config);
            location.assign(path);
        }
    }

    //All merge fields generated go through this to handle special cases
    function getMergeField(objectName, fieldName) {
        if(objectName == 'Contact' && fieldName == 'AccountId')
            return '{!Account.Id}';
        else
            return '{!' + objectName + '.' + fieldName + '}';
    }

    function getSelectedField(section) {
        if($scope['selectedObject' + section] != null && $scope['selectedField' + section] != null)
            return getMergeField($scope['selectedObject' + section].value, $scope['selectedField' + section].value);
        else
            return '';
    }

    $scope.needTemplate = function() {
        if(config == null)
            return true;

        return config[PKG_NS_PREFIX + 'New_Template_Needed__c'];
    }

    $scope.setFieldDefault = function(section) {
        $scope['selectedField' + section] = $scope['selectedObject' + section].fields[0];
    }

    $scope.insertField = function(section) {
        var mergeField = getSelectedField(section);
        var textArea = document.getElementById(section.toLowerCase());
        var ss = textArea.selectionStart;
        var se = textArea.selectionEnd;

        textArea.value = textArea.value.substring(0, ss) + mergeField + textArea.value.substring(se);
        textArea.focus();
        textArea.selectionStart = textArea.selectionEnd = ss + mergeField.length;

        //Manually sync the model to match the updated DOM value (this was done in reverse of the Angular way to preserve the selection manually set above)
        $scope[section.toLowerCase()] = textArea.value;
    }

    $scope.createTemplate = function() {
        $scope.name = $scope.name.trim();

        $scope.nameRequired = false;
        if($scope.name == '') {
            $scope.nameRequired = true;
            return;
        }

        $scope.subject = $scope.subject.trim();

        $scope.subjectRequired = false;
        if($scope.subject == '') {
            $scope.subjectRequired = true;
            return;
        }

        if(arguments.length == 0) {
            ctrl.checkTemplateExists($scope.name, $scope.folderId).then(function(alreadyExists) {
                if(alreadyExists)
                    $scope.showDuplicateTemplateConfirmation = true;
                else
                    continueCreateTemplate();
            });
        }
        else {
            $scope.showDuplicateTemplateConfirmation = false;
            continueCreateTemplate();
        }

        function continueCreateTemplate() {
            var template = $scope.template.replace('[[GREETING]]', $scope.greeting.replace(/\n/g, '<br/>')).replace('[[FAREWELL]]', $scope.closing.replace(/\n/g, '<br/>')).replace('[[LINKS]]', generateLinks(config, false));
            if(PKG_NS_PREFIX == '')
                template = template.replace(/simplesurvey__/g, '');

            // customization
            if($scope.customizeEmailTemplate == 'Color'){
                template = template.replace(new RegExp('bgcolor="#.*"', 'g'), 'bgcolor="' + $scope.emailTemplateColor + '"');
                // only ends up white
                // template = template.replace(new RegExp('bgcolor="#.*"', 'g'), '');
                // template = template.replace('style="font-family: Arial, serif"', 'style="font-family: Arial, serif; background-color:' + $scope.emailTemplateColor + ';');
            }
            else if($scope.customizeEmailTemplate == 'Image'){
                template = template.replace(new RegExp('bgcolor="#.*"', 'g'), '');
                // template = template.replace('style="font-family: Arial, serif"', 'style="font-family: Arial, serif; background-image: url(\'' + $scope.emailTemplateImage + '\'); background-position: 0px 0px;"');
                template = template.replace('/*SURVEY_BUILDER_BG_STYLE*/', 'background-image: url(\'' + $scope.emailTemplateImage + '\'); background-position: 0px 0px;');
            }
            else if($scope.customizeEmailTemplate == 'Document'){
                template = template.replace(new RegExp('bgcolor="#.*"', 'g'), '');
                template = template.replace('/*SURVEY_BUILDER_BG_STYLE*/', 'background-image: url(\'' + $scope.baseImgUrl + '&id=' + $scope.emailTemplateDocument + '\'); background-position: 0px 0px;');
            }

            //DeveloperName + currentDate.format('yyMMdd_hhmmss')
            var developerName = util.generateName($scope.name) + '_' + (new Date()).toISOString().substring(2,19).replace(/[^\dT]/g, '').replace('T', '_');

            config[PKG_NS_PREFIX + 'Last_Email_Template_Greeting__c'] = $scope.greeting;
            config[PKG_NS_PREFIX + 'Last_Email_Template_Closing__c'] = $scope.closing;
            config[PKG_NS_PREFIX + 'Last_Step_Completed__c'] = 'Create Email Template';
            config[PKG_NS_PREFIX + 'Subject__c'] = $scope.subject;
            config[PKG_NS_PREFIX + 'Customize_Email_Template__c'] = $scope.customizeEmailTemplate == 'none' ? '' : $scope.customizeEmailTemplate;
            config[PKG_NS_PREFIX + 'Email_Template_Image__c'] = $scope.emailTemplateImage;
            config[PKG_NS_PREFIX + 'Email_Template_Color__c'] = $scope.emailTemplateColor;
            config[PKG_NS_PREFIX + 'Email_Template_Document__c'] = $scope.emailTemplateDocument == 'none' ? '' : $scope.emailTemplateDocument;

            $scope.processing = true;
            $scope.processingLabel = 'Creating Email Template...';
            ctrl.insertTemplate($scope.name, developerName, $scope.subject, $scope.description, template, $scope.folderId).then(function(templateId) {
                if(templateId != null) {
                    if((PKG_NS_PREFIX + 'Last_Created_Template_Id__c') in config && config[PKG_NS_PREFIX + 'Last_Created_Template_Id__c'].trim() != '' && config[PKG_NS_PREFIX + 'Last_Created_Template_Id__c'] != templateId)
                        $scope.isFirstEmailTemplate = false;

                    config[PKG_NS_PREFIX + 'Last_Created_Template_Id__c'] = templateId;
                    config[PKG_NS_PREFIX + 'New_Template_Needed__c'] = false;
                    $scope.processingLabel = 'Saving Configuration...';
                    ctrl.saveConfiguration(config).then(function(result) {
                        $scope.processing = false;
                        $scope.lastCreatedTemplateName = $scope.name;
                        $scope.lastCreatedTemplateId = templateId;
                    });
                }
                else {
                    $scope.processing = false;
                    $scope.alertType = 'error';
                    $scope.alertTitle = 'Error';
                    $scope.alertMessage = 'An error occurred while saving the template';
                    $scope.alertShow = true;
                }
            });
        }
    }

    $scope.emailSentDismissed = true;
    $scope.send = function() {
        var template = $scope.template.replace('[[GREETING]]', $scope.greeting).replace('[[FAREWELL]]', $scope.closing).replace('[[LINKS]]', generateLinks(config, true));
        ctrl.sendInstructions(template, util.generateFileName($scope.name) + '.txt').then(function(result) {
            if(result == null)
                $scope.emailSentMessage = 'Email successfully sent to ' + USER_EMAIL;
            else
                $scope.emailSentMessage = result;

            $scope.emailSentDismissed = false;
        });
    }

    var defaultGreetings = {
        '0-10': 'How likely are you to recommend {!Organization.Name} to a friend or colleague based on your experience with {!Case.OwnerFullName}? Please respond by clicking below:',
        '1-5': 'On a scale of 1 to 5, how satisfied are you with {!Case.OwnerFullName} ... ',
        'None': 'Your feedback is important to us. Please take a moment to fill out our brief survey.'
    };
    var defaultClosing = 'Thank you,\n{!User.Name}';

    $scope.setDefaultGreetingClosing = function() {
        $scope.greeting = defaultGreetings[config[PKG_NS_PREFIX + 'Rating_Scale__c']];
        $scope.closing = defaultClosing;
    }

    function generateLinks(config, mergeSiteURL) {
        var links = '';

        if(config[PKG_NS_PREFIX + 'Rating_Scale__c'] == '1-5') {
            var labels = ['', 'Very Dissatisfied', 'Dissatisfied', 'Fair', 'Satisfied', 'Very Satisfied'];

            for(var i = 5; i > 0; i--) {
                links += '<a style="text-decoration: none; color: #222222;" href="' + getRatingHref(config, i, mergeSiteURL) + '" border="0" alt="' + i + '" />&nbsp;\n' +
                         '<img src="{!$Setup.' + PKG_NS_PREFIX + 'Simple_Survey_Setting__c.' + PKG_NS_PREFIX + 'Survey_Rate_' + i + '_IMG__c}" border="0" alt="' + i + '" />' +
                         '    <span  style="text-decoration: underline;">' + labels[i] + '&#8203;</span>\n' +
                         '</a>\n' +
                         '<br/><br/>\n';
            }
        }
        else if(config[PKG_NS_PREFIX + 'Rating_Scale__c'] == '0-10') {
            var colorCodes = ['#cf4b4b', '#cf5744', '#cf6d38', '#cf9024', '#cfa11a', '#caa615', '#b0a514', '#879d15', '#599216', '#2b8719', 'green'];

            for(var i = 0; i < 11; i++) {
                links += '<td>\n' +
                         '    <a style="text-decoration: none; color: ' + colorCodes[i] + '; font-weight: bold;" href="' + getRatingHref(config, i, mergeSiteURL) + '"><span  style="text-decoration: none;">' + i + '&#8203;</span></a>\n'
                         '</td>\n';
            }
        }
        else if(config[PKG_NS_PREFIX + 'Rating_Scale__c'] == 'None') {
            links = '<a href="' + getRatingHref(config, null, mergeSiteURL) + '">Click here to take our survey</a><br/><br/>\n';
        }

        return links;
    }

    function getRatingHref(config, score, mergeSiteURL) {
        var link;
        if(!mergeSiteURL)
            link = '{!$Setup.' + PKG_NS_PREFIX + 'Simple_Survey_Setting__c.' + PKG_NS_PREFIX + 'Survey_Site_URL__c}';
        else
            link = settings[PKG_NS_PREFIX + 'Survey_Site_URL__c'];
        var params = [];

        if(config[PKG_NS_PREFIX + 'Rating_Scale__c'] == '1-5') {
            params.push('ratingType=1');
            params.push(PKG_NS_PREFIX + 'Rating_Scale__c=1-5');
        }
        else if(config[PKG_NS_PREFIX + 'Rating_Scale__c'] == '0-10') {
            params.push('ratingType=2');
            params.push(PKG_NS_PREFIX + 'Rating_Scale__c=0-10');
        }
        else if(config[PKG_NS_PREFIX + 'Rating_Scale__c'] == 'None')
            params.push('ratingType=3');

        params.push('RecordTypeId=' + config[PKG_NS_PREFIX + 'Record_Type__c']);
        params.push('fieldset=' + encodeURIComponent(config[PKG_NS_PREFIX + 'Field_Set__c'].split('.')[1]));
        params.push('lang=' + $scope.language);

        if(config[PKG_NS_PREFIX + 'Rating_Scale__c'] != 'None')
            params.push(PKG_NS_PREFIX + 'Survey_Score__c=' + score);

        if(config[PKG_NS_PREFIX + 'Picklist_Display__c'] == 'Vertical Radio Buttons' || config[PKG_NS_PREFIX + 'Picklist_Display__c'] == 'Horizontal Radio Buttons') {
            params.push('radioPicklistOptions=true');
            params.push('horizontalRadios=' + config[PKG_NS_PREFIX + 'Picklist_Display__c'] == 'Horizontal Radio Buttons');
        }
        else
            params.push('radioPicklistOptions=false');

        if(config[PKG_NS_PREFIX + 'Multiselect_Picklist_Display__c'] == 'Vertical Checkboxes' || config[PKG_NS_PREFIX + 'Multiselect_Picklist_Display__c'] == 'Horizontal Checkboxes') {
            params.push('checkboxPicklistOptions=true');
            params.push('horizontalCheckboxes=' + config[PKG_NS_PREFIX + 'Multiselect_Picklist_Display__c'] == 'Horizontal Checkboxes');
        }
        else
            params.push('checkboxPicklistOptions=false');

        var mappings = angular.fromJson(config[PKG_NS_PREFIX + 'Survey_Object_Field_Assignment__c']);
        for(var surveyField in mappings) {
            if(mappings[surveyField].type == 'field')
                params.push(surveyField + '=' + getMergeField(config[PKG_NS_PREFIX + 'Survey_Object__c'], mappings[surveyField].value));
            else if(mappings[surveyField].type == 'value')
                params.push(surveyField + '=' + encodeURIComponent(mappings[surveyField].value));
        }

        link += '?' + params.join('&');
        return link;
    }

    $scope.processing = true;
    $scope.processingLabel = 'Loading Template Information...';
    ctrl.getTemplateInfo($routeParams.id).then(function(result) {
        settings = result.settings;
        config = result.configuration;

        if((PKG_NS_PREFIX + 'Last_Created_Template_Id__c') in config && config[PKG_NS_PREFIX + 'Last_Created_Template_Id__c'].trim() != '')
            $scope.isFirstEmailTemplate = false;

        if((PKG_NS_PREFIX + 'Last_Email_Template_Closing__c') in config)
            $scope.closing = config[PKG_NS_PREFIX + 'Last_Email_Template_Closing__c'];
        else
            $scope.closing = defaultClosing;

        if((PKG_NS_PREFIX + 'Last_Email_Template_Greeting__c') in config)
            $scope.greeting = config[PKG_NS_PREFIX + 'Last_Email_Template_Greeting__c'];
        else
            $scope.greeting = defaultGreetings[config[PKG_NS_PREFIX + 'Rating_Scale__c']];

        if('template' in result)
            $scope.template = result.template;

        $scope.folderOptions = result.folders;
        $scope.folderId = result.defaultFolderId;

        $scope.objectOptions = result.objectFieldInfo;
        $scope.selectedObjectGreeting = $scope.objectOptions[0];
        $scope.selectedFieldGreeting = $scope.selectedObjectGreeting.fields[0];
        $scope.selectedObjectClosing = $scope.objectOptions[0];
        $scope.selectedFieldClosing = $scope.selectedObjectClosing.fields[0];
        $scope.selectedObjectSubject = $scope.objectOptions[0];
        $scope.selectedFieldSubject = $scope.selectedObjectSubject.fields[0];
        $scope.name = result.configuration.Name;
        $scope.processing = false;
        $scope.subject = result.configuration[PKG_NS_PREFIX + 'Subject__c'];

        $scope.customizeEmailTemplate = result.configuration[PKG_NS_PREFIX + 'Customize_Email_Template__c'];
        $scope.emailTemplateImage = result.configuration[PKG_NS_PREFIX + 'Email_Template_Image__c'];
        $scope.emailTemplateColor = result.configuration[PKG_NS_PREFIX + 'Email_Template_Color__c'];
        if($scope.customizeEmailTemplate == undefined)
            $scope.customizeEmailTemplate = 'none';
        // default the email template subejct
        if($scope.subject == null || $scope.subject == '')
            $scope.subject = 'Customer Satisfaction Survey (Respond with 1 Click)';

        $scope.emailTemplateDocumentOptions = result.documentImages;
        $scope.emailTemplateDocument = result.configuration[PKG_NS_PREFIX + 'Email_Template_Document__c'];
        if($scope.emailTemplateDocument == undefined)
            $scope.emailTemplateDocument = 'none';
    });
    // get the base url for document images
    ctrl.getBaseUrl($scope.emailTemplateDocument, function(url){
        console.log('url = ' + url);
        $scope.baseImgUrl = url;
    });
}]);


// --( Utility Service )--
SurveyBuilder.service('util', ['$q', '$timeout', function($q, $timeout) {
    //Just to note, I do not trust the promises returned by JSforce methods since they may lie about success
    //Results are manually checked in the callback parameters instead
    var conn = new jsforce.Connection({accessToken: SESSION_ID});

    this.nsPrefix = DEVELOPER_ORG ? 'simplesurvey__' : ''
    var nsPrefix = this.nsPrefix; //For use by asynchronous actions defined in util

    //Recursively escapes XML entities in object fields / arrays / text
    this.escapeXMLEntities = function(obj) {
        if(typeof obj == 'string')
            return obj.replace(/&/g, '&amp;')
                      .replace(/'/g, '&apos;')
                      .replace(/"/g, '&quot;')
                      .replace(/</g, '&lt;')
                      .replace(/>/g, '&gt;');
        else if(typeof obj == 'object') {
            for(var field in obj)
                obj[field] = escapeXMLEntities(obj[field]);
        }
        return obj;
    }
    var escapeXMLEntities = this.escapeXMLEntities; //For use by asynchronous actions defined in util

    //Recursively unescapes XML entities in object fields / arrays / text
    this.unescapeXMLEntities = function(obj) {
        if(typeof obj == 'string')
            return obj.replace(/(&quot;)|(&#34;)/g, '"')
                      .replace(/(&apos;)|(&#39;)/g, "'")
                      .replace(/(&lt;)|(&#60;)/g, '<')
                      .replace(/(&gt;)|(&#62;)/g, '>')
                      .replace(/(&amp;)|(&#38;)/g, '&');
        else if(typeof obj == 'object')
            for(var field in obj)
                obj[field] = unescapeXMLEntities(obj[field]);
        return obj;
    }
    var unescapeXMLEntities = this.unescapeXMLEntities; //For use by asynchronous actions defined in util

    //Generates an API name based on a label
    this.generateName = function(label) {
        return '' + label.replace(/^[^\da-z]+|[^\da-z]+$|[^\da-z ]| (?=[^\da-z]* )/gi, '').replace(/ /g, '_').replace(/(^\d)/, 'X$1');
    }

    //Strip invalid or undesired characters from text for filename
    this.generateFileName = function(text) {
        return text.replace(/[\/:*?"<>|.'\r\n]/g, '');
    }

    this.extractErrors = function(reason) {
        if(reason instanceof Array) {
            var errors = [];
            reason.forEach(function(reason) {
                errors.push(reason.errors.message);
            });
            return errors.join('<br/>');
        }
        else if('errors' in reason)
            return reason.errors.message;
        else
            return reason;
    }

    this.removeDirtyFlag = function() {
        [].forEach.call(document.querySelectorAll('.ng-dirty'), function(element) {
            element.className = element.className.replace(/ ?ng-dirty ?/, '');
        });
    }

    //Returns the supplied object as an array
    this.asArray = function(obj) {
        if(obj === undefined)
            return [];
        return [].concat.call([], obj);
    }
    var asArray = this.asArray; //For use by asynchronous actions defined in util

    this.createSurveyLayout = function(name, includeScore) {
        return $q(function(resolve, reject) {
            var metadata = {
                fullName: PKG_NS_PREFIX + "Survey__c-" + (nsPrefix == '' ? (PKG_NS_PREFIX != '' ? '__' : '') : nsPrefix) + escapeXMLEntities(name),
                excludeButtons: "Submit",
                layoutSections: [
                    {
                        customLabel: true,
                        detailHeading: false,
                        editHeading: false,
                        label: "Survey Information",
                        layoutColumns: [
                            {
                                layoutItems: [
                                    {
                                        behavior: "Edit",
                                        field: PKG_NS_PREFIX + "Rating_Scale__c"
                                    },
                                    {
                                        behavior: "Edit",
                                        field: PKG_NS_PREFIX + "Record_Owner__c"
                                    }
                                ]
                            },
                            ""
                        ],
                        style: "TwoColumnsTopToBottom"
                    },
                    {
                        customLabel: "true",
                        detailHeading: "true",
                        editHeading: "true",
                        label: "Questions",
                        layoutColumns: [""],
                        style: "OneColumn"
                    },
                    {
                        customLabel: false,
                        detailHeading: true,
                        editHeading: true,
                        label: "System Information",
                        layoutColumns: [
                            {
                                layoutItems: [
                                    {
                                        behavior: "Readonly",
                                        field: "Name"
                                    },
                                    {
                                        behavior: "Edit",
                                        field: "OwnerId"
                                    },
                                    {
                                        behavior: "Edit",
                                        field: "RecordTypeId"
                                    }
                                ]
                            },
                            {
                                layoutItems: [
                                    {
                                        behavior: "Readonly",
                                        field: "CreatedById"
                                    },
                                    {
                                        behavior: "Readonly",
                                        field: "LastModifiedById"
                                    }
                                ]
                            }
                        ],
                        style: "TwoColumnsTopToBottom"
                    },
                    {
                        customLabel: "true",
                        detailHeading: "true",
                        editHeading: "false",
                        label: "Custom Links",
                        layoutColumns: ["", "", ""],
                        style: "CustomLinks"
                    }
                ],
                relatedLists: [
                    {
                        fields: [
                            "TASK.SUBJECT",
                            "TASK.WHO_NAME",
                            "ACTIVITY.TASK",
                            "TASK.DUE_DATE",
                            "TASK.STATUS",
                            "TASK.PRIORITY",
                            "CORE.USERS.FULL_NAME"
                        ],
                        relatedList: "RelatedActivityList"
                    },
                    {
                        fields: [
                            "TASK.SUBJECT",
                            "TASK.WHO_NAME",
                            "ACTIVITY.TASK",
                            "TASK.DUE_DATE",
                            "CORE.USERS.FULL_NAME",
                            "TASK.LAST_UPDATE"
                        ],
                        relatedList: "RelatedHistoryList"
                    },
                    {
                        relatedList: "RelatedEntityHistoryList"
                    }
                ],
                showEmailCheckbox: "false",
                showHighlightsPanel: "false",
                showInteractionLogPanel: "false",
                showRunAssignmentRulesCheckbox: "false",
                showSubmitAndAttachButton: "false"
            };

            if(includeScore)
                metadata.layoutSections[0].layoutColumns[0].layoutItems.unshift({
                    behavior: "Edit",
                    field: PKG_NS_PREFIX + "Survey_Score__c"
                });

            conn.metadata.create('Layout', metadata, function(err, result) {
                if(result.success) {
                    result.fullName = result.fullName.replace('-__', '-.__');
                    resolve(result)
                }
                else
                    reject(result);
            });
        });
    }

    this.createSurveyRecordType = function(name, label) {
        return $q(function(resolve, reject) {
            var metadata = escapeXMLEntities({
                fullName: PKG_NS_PREFIX + "Survey__c." + nsPrefix + name,
                active: "true",
                label: label
            });

            conn.metadata.create('RecordType', metadata, function(err, result) {
                result.success ? resolve(result) : reject(result);
            });
        });
    }

    this.createSurveyFieldSet = function(name, label) {
        return $q(function(resolve, reject) {
            var metadata = escapeXMLEntities({
                fullName: PKG_NS_PREFIX + "Survey__c." + nsPrefix + name,
                description: "Fields for " + label,
                label: label
            });

            conn.metadata.create('FieldSet', metadata, function(err, result) {
                result.success ? resolve(result) : reject(result);
            });
        });
    }

    this.saveFieldSet = function(fieldSetMetadata) {
        var metadata = escapeXMLEntities(angular.copy(fieldSetMetadata));

        return $q(function(resolve, reject) {
            conn.metadata.update('FieldSet', metadata, function(error, result) {
                result.success ? resolve(result) : reject(result);
            });
        });
    }

    this.assignLayout = function(layoutName, recordTypeName) {
        return $q(function(resolve, reject) {
            conn.metadata.list({type: 'Profile'}, function(err, result) {
                if(err != null) {
                    reject(err);
                    return;
                }

                //Create array of metadata for each profile to update the layout assignment
                var metadata = escapeXMLEntities(result.reduce(function(acc, item) {
                    //Limit to the admin and current user profile for now to increase speed (turns out updating all profiles is really slow)
                    //Note that Profile.Name is not necessarily equal to the metadata profile fullName so Id is checked instead
                    if(item.fullName == 'Admin' || item.id == PROFILE_ID) {
                        return acc.concat({
                            fullName: item.fullName,
                            layoutAssignments: [{
                                layout: PKG_NS_PREFIX + 'Survey__c-' + nsPrefix + layoutName,
                                recordType: PKG_NS_PREFIX + 'Survey__c.' + nsPrefix + recordTypeName
                            }]
                        });
                    }
                    return acc;
                }, []));

                //Can only update up to 10 records at a time
                //Build list of promises for each batch of 10
                var promises = [];
                for(var i = 0; i < metadata.length; i += 10) {
                    promises.push($q(function(resolve, reject) {
                        conn.metadata.update('Profile', metadata.slice(i, (i + 10 < metadata.length) ? (i + 10) : metadata.length), function(err, results) {
                            if(err != null) {
                                reject(err);
                                return;
                            }
                            for(var j = 0; j < results.length; j++) {
                                if(!results[j].success) {
                                    reject(results);
                                    return;
                                }
                            }
                            resolve(results);
                        });
                    }));
                }

                //Once all batches of 10 have finished running then resolve
                $q.all(promises).then(function(results) {
                    resolve(results);
                }).catch(function(err) {
                    reject(err);
                })
            });
        });
    }

    this.getSurveyMetadata = function() {
        return $q(function(resolve, reject) {

            conn.metadata.read('CustomObject', PKG_NS_PREFIX + 'Survey__c', function(err, result) {
                $timeout(function() {
                    if('fullName' in result)
                        resolve(result);
                    else
                        reject(result);
                });
            });
        });
    }

    this.createField = function(name, label, type, description, helpText, visibleLines, picklistOptions, decimalPlaces, referenceTo) {
        return $q(function(resolve, reject) {
            var metadata = {
                fullName: PKG_NS_PREFIX + 'Survey__c.' + nsPrefix + name,
                label: label,
                inlineHelpText: helpText,
                type: type,
                description: description
            };

            if(type == 'Text')
                metadata.length = '255';
            else if(type == 'LongTextArea')
                metadata.length = '32768';

            if(type == "Checkbox")
                metadata.defaultValue = false;

            if(type == 'Currency' || type == 'Number' || type == 'Percent') {
                metadata.precision = 18;
                metadata.scale = decimalPlaces;
            }

            if(type == 'Picklist' || type == 'MultiselectPicklist') {
                var values = [];
                picklistOptions.forEach(function(val) {
                    values.push({
                        fullName: val.trim(),
                        "default": false
                    });
                });

                metadata.picklist = {
                    picklistValues: values,
                    sorted: false
                };
            }

            if(type == 'MultiselectPicklist' || type == 'LongTextArea') {
                metadata.visibleLines = parseInt(visibleLines);
            }

            if(type == 'Lookup') {
                metadata.referenceTo = referenceTo;
                metadata.relationshipName = name.replace('__c', 's');
            }

            var resultMatadata = angular.copy(metadata);
            var escapedMetadata = escapeXMLEntities(metadata);

            conn.metadata.create('CustomField', escapedMetadata, function(error, result) {
                $timeout(function() {
                    if(result.success) {
                        resolve(resultMatadata);
                    }
                    else
                        reject(result);
                });
            });
        });
    }

    this.addFieldsToLayout = function(layoutName, fieldNames, rightColumn, preferredSectionLabel) {
        return $q(function(resolve, reject) {
            conn.metadata.read('Layout', layoutName, function(error, result) {
                if(error != null)
                    reject(error);
                else {
                    //asArray is used since the property may be an empty string or a single object instead of an Array if there are 1 or fewer elements
                    var layoutFields = {};
                    asArray(result.layoutSections).forEach(function(section) {
                        asArray(section.layoutColumns).forEach(function(column) {
                            asArray(column.layoutItems).forEach(function(item) {
                                if(typeof item == 'object' && 'field' in item)
                                    layoutFields[item.field] = 1;
                            });
                        });
                    });

                    var sectionIndex = -1;

                    //Try to select the preferred section by label
                    if(preferredSectionLabel != null) {
                        for(var i = 0; i < result.layoutSections.length; i++) {
                            if(result.layoutSections[i].style != 'CustomLinks' && result.layoutSections[i].label == preferredSectionLabel) {
                                sectionIndex = i;
                                break;
                            }
                        }
                    }

                    //Default to first section that is not Custom Links
                    if(sectionIndex == -1) {
                        for(var i = 0; i < result.layoutSections.length; i++) {
                            if(result.layoutSections[i].style != 'CustomLinks') {
                                sectionIndex = i;
                                break;
                            }
                        }
                    }

                    //Add new section for custom fields if necessary (only section on the layout currently is Custom Links)
                    if(sectionIndex == -1) {
                        sectionIndex = 0;
                        var sectionInsert = {
                            customLabel: "true",
                            detailHeading: "true",
                            editHeading: "true",
                            label: "Survey Fields",
                            layoutColumns: [{layoutItems: []}, ''],
                            style: "TwoColumnsTopToBottom"
                        };

                        if(result.layoutSections instanceof Array)
                            result.layoutSections.unshift(sectionInsert);
                        else
                            result.layoutSections = [sectionInsert, result.layoutSections];
                    }

                    //`layoutColumns` is returned by JSForce as an object on single column layouts instead of an array with a single item
                    if(!(result.layoutSections[sectionIndex].layoutColumns instanceof Array))
                        result.layoutSections[sectionIndex].layoutColumns = [result.layoutSections[sectionIndex].layoutColumns];

                    var column = 0;
                    if(rightColumn == true && result.layoutSections[sectionIndex].layoutColumns.length == 2)
                        column = 1;

                    //Make sure layoutSections[sectionIndex].layoutColumns[column].layoutItems exists and is an array
                    if(typeof result.layoutSections[sectionIndex].layoutColumns[column] == 'string')
                        result.layoutSections[sectionIndex].layoutColumns[column] = {layoutItems: []};
                    else if(!(result.layoutSections[sectionIndex].layoutColumns[column].layoutItems instanceof Array))
                        result.layoutSections[sectionIndex].layoutColumns[column].layoutItems = [result.layoutSections[sectionIndex].layoutColumns[column].layoutItems];

                    //Add missing fields to the layout
                    fieldNames.forEach(function(fieldName) {
                        if(!(fieldName in layoutFields)) {
                            result.layoutSections[sectionIndex].layoutColumns[column].layoutItems.push({
                                behavior: 'Edit',
                                field: fieldName
                            });
                        }
                    });

                    //Update metadata
                    conn.metadata.update('Layout', escapeXMLEntities(result), function(error, result) {
                        result.success ? resolve(result) : reject(result);
                    });
                }
            });
        });
    }

    this.updateFieldSecurity = function(fieldNames) {
        return $q(function(resolve, reject) {
            conn.metadata.list({type: 'Profile'}, function(err, result) {
                if(err != null) {
                    reject(err);
                    return;
                }

                var profileFullNames = result.reduce(function(acc, profile) {
                    //Limit to the admin, current user profile, and site guest profile for now to increase speed (turns out updating all profiles is really slow)
                    //Note that Profile.Name is not necessarily equal to the metadata profile fullName
                    if(profile.fullName == 'Admin' || profile.fullName == 'Simple Survey Profile' || profile.id == PROFILE_ID)
                        return acc.concat(profile.fullName);
                    return acc;
                }, []);

                conn.metadata.read('Profile', profileFullNames, function(err, result) {
                    //Create array of metadata for each profile to update the layout assignment
                    var metadata = escapeXMLEntities(asArray(result).reduce(function(acc, profile) {
                        var permByName = {};
                        profile.fieldPermissions.forEach(function(fp) {
                            permByName[fp.field] = fp;
                        });

                        //Check existing field permissions in case no changes are needed for a field (otherwise a vague error will occur: "duplicate value found: <unknown> duplicates value on record with id: <unknown>")
                        var newFieldPerms = [];
                        fieldNames.forEach(function(fieldName) {
                            var fullFieldName = PKG_NS_PREFIX + 'Survey__c.' + fieldName;

                            if(permByName[fullFieldName].editable == "false" || permByName[fullFieldName].readable == "false") {
                                newFieldPerms.push({
                                    field: fullFieldName,
                                    editable: true,
                                    readable: true
                                });
                            }
                        });

                        //Check Survey__c object permissions for Simple Survey Profile
                        var newObjPerms = [];
                        if(profile.fullName == 'Simple Survey Profile') {
                            var foundSurveyObject = false;

                            //Check for existing Survey__c object permissions and update if needed
                            asArray(profile.objectPermissions).forEach(function(op) {
                                //At least Create, Read, and Edit are required
                                if(op.object == PKG_NS_PREFIX + 'Survey__c') {
                                    foundSurveyObject = true;

                                    if(op.allowCreate == "false" || op.allowRead == "false" || op.allowEdit == "false") {
                                        op.allowCreate = true;
                                        op.allowRead = true;
                                        op.allowEdit = true;
                                        newObjPerms.push(op);
                                    }
                                }
                            });

                            //No Survey__c object permissions exist yet, set defaults
                            if(!foundSurveyObject) {
                                newObjPerms.push({
                                    object: PKG_NS_PREFIX + "Survey__c",
                                    allowCreate: true,
                                    allowRead: true,
                                    allowEdit: true,
                                    allowDelete: false,
                                    viewAllRecords: false,
                                    modifyAllRecords: false
                                });
                            }
                        }

                        if(newFieldPerms.length > 0 || newObjPerms.length > 0)
                            return acc.concat({
                                fullName: profile.fullName,
                                fieldPermissions: newFieldPerms,
                                objectPermissions: newObjPerms
                            });
                        return acc;
                    }, []));

                    //Update field security
                    if(metadata.length > 0) {
                        conn.metadata.update('Profile', metadata, function(error, results) {
                            if(error != null) {
                                reject(error);
                                return;
                            }
                            for(var j = 0; j < results.length; j++) {
                                if(!results[j].success) {
                                    reject(results);
                                    return;
                                }
                            }
                            resolve(results);
                        });
                    }
                    else
                        resolve([]);
                });
            });
        });
    }

    this.getSurveyToolingIds = function() {
        var result = {
            objectId: null,
            fieldIdsByName: {}
        };

        return $q(function(resolve, reject) {
            conn.tooling.query('SELECT Id FROM CustomObject WHERE DeveloperName = \'Survey\' AND NamespacePrefix = \'simplesurvey\'', function(err, response) {
                if(response.records.length == 1) {
                    result.objectId = response.records[0].Id;

                    conn.tooling.query('SELECT Id, DeveloperName, NamespacePrefix FROM CustomField WHERE TableEnumOrId = \'' + result.objectId + '\'', function(err, response) {
                        response.records.forEach(function(field) {
                            var prefix = field.NamespacePrefix != null ? (field.NamespacePrefix + '__') : '';
                            //Salesforce randomly included the prefix for RecordType FullName in Summer 16 so one would not be surprised if this broke in a future release as well
                            if(prefix != '' && field.DeveloperName.indexOf(prefix) != 0)
                                result.fieldIdsByName[prefix + field.DeveloperName + '__c'] = field.Id;
                            else
                                result.fieldIdsByName[field.DeveloperName + '__c'] = field.Id; //Proactive potential fix
                        });

                        $timeout(function() {
                            resolve(result);
                        });
                    });
                }
                else
                    $timeout(reject);
            });
        });
    }

    this.addPicklistValuesToRecordType = function(recordTypeId, fields) {
        return $q(function(resolve, reject) {
            var picklists = [];

            fields.forEach(function(field) {
                if(field.type == 'Picklist' || field.type == 'MultiselectPicklist') {
                    picklists.push({
                        picklist: field.fullName,
                        values: angular.copy(field.picklist.picklistValues) //Cloned to prevent double encodeURIComponent in successive saves
                    });
                }
            });

            if(picklists.length == 0) {
                $timeout(resolve);
                return;
            }

            //Get fullName by Id used to retrieve the metadata (the Metadata field on RecordType does not contain the picklist values)
            conn.tooling.query('SELECT FullName FROM RecordType WHERE Id = \'' + recordTypeId + '\' LIMIT 1', function(err, response) {
                if(response.records.length == 1) {
                    //Summer 16 randomly started including the package namespace prefix in the FullName
                    var fullName = response.records[0].FullName;
                    if(PKG_NS_PREFIX != '' && fullName.indexOf(PKG_NS_PREFIX) != 0)
                        fullName = PKG_NS_PREFIX + fullName;

                    conn.metadata.read('RecordType', fullName, function(err, result) {
                        if(err != null) {
                            $timeout(function(){ reject(err); });
                            return;
                        }

                        //Get all existing pick-list values by name
                        var picklistValuesByName = {};
                        asArray(result.picklistValues).forEach(function(entry) {
                            picklistValuesByName[entry.picklist] = entry;
                        });

                        //Append values not yet added and ridiculous URL encoding since the API expects that for no logical reason for some characters
                        picklists.forEach(function(entry) {
                            entry.values = asArray(entry.values); //JSForce returns a single value as an object

                            for(var i = 0; i < entry.values.length; i++)
                                entry.values[i].fullName = encodeURIComponent(entry.values[i].fullName);

                            picklistValuesByName[entry.picklist] = entry;
                        });

                        //Rebuild silly array for the API
                        result.picklistValues = [];
                        for(var key in picklistValuesByName)
                            result.picklistValues.push(picklistValuesByName[key]);

                        conn.metadata.update('RecordType', escapeXMLEntities(result), function(err, result) {
                            $timeout(function() {
                                if(err != null)
                                    reject(err);

                                if(('success' in result) && result.success)
                                    resolve(result)
                                else
                                    reject(result)
                            });
                        });
                    });
                }
                else
                    $timeout(reject);
            });
        });
    }
}]);


// --( Apex Controller Service )--
SurveyBuilder.factory('ctrl', ['$q', '$timeout', 'util', function($q, $timeout, util) {
    if(window.simplesurvey == null)
        window.simplesurvey = window;

    //Modify the remote actions to return a promise that will resolve with the unescaped results.
    for(var methodName in simplesurvey.SurveyBuilderController) {
        var originalMethod = simplesurvey.SurveyBuilderController[methodName];

        //Assigned to a closure which invokes the original method and returns a promise
        simplesurvey.SurveyBuilderController[methodName] = (function(originalMethod) {
            return function() {
                var parameters = [].slice.call(arguments);

                return $q(function(resolve, reject) {
                    parameters.push(function(result) {
                        //Insure digest cycle runs
                        $timeout(function() {
                            resolve(util.unescapeXMLEntities(result));
                        });
                    });

                    originalMethod.apply(simplesurvey.SurveyBuilderController, parameters);
                });
            }
        })(originalMethod);
    }

    return simplesurvey.SurveyBuilderController;
}]);


// --( ss-tooltip Directive )--
SurveyBuilder.directive('ssTooltip', function() {
    return {
        restrict: 'E', //Elements only
        scope: {
            show: '=show'
        },
        transclude: true,
        template: '<div ng-show="show" style="position: fixed; left: {{x}}px; top: {{y}}px; z-index: 9999;" class="slds-popover slds-popover--tooltip slds-nubbin--{{nubbin}}" role="tooltip">' +
                  '    <div class="slds-popover__body" ng-transclude></div>' +
                  '</div>',
        link: function(scope, element, attrs) {
            scope.x = 0;
            scope.y = 0;
            if('nubbin' in attrs)
                scope.nubbin = attrs.nubbin;
            else
                scope.nubbin = 'bottom';

            window.addEventListener('mousemove', function(e) {
                var sw = window.clientWidth;
                var sh = window.clientHeight;

                switch(scope.nubbin) {
                    case 'top-left':
                        scope.x = e.clientX - 32;
                        scope.y = e.clientY + 32;
                        break;
                    case 'bottom-left':
                        scope.x = e.clientX - 32;
                        scope.y = e.clientY - element[0].firstElementChild.clientHeight - 20;
                        break;
                    default: //bottom
                        scope.x = e.clientX - element[0].firstElementChild.clientWidth / 2;
                        scope.y = e.clientY - element[0].firstElementChild.clientHeight - 20;
                        break;
                }
                scope.$digest();
            });
        }
    };
});


// --( ss-lookup Directive )--
SurveyBuilder.directive('ssLookup', function() {
    return {
        restrict: 'E', //Elements only
        scope: {
            label: '=label',
            value: '=value',
            options: '=options'
        },
        template: '<div class="slds-input-has-icon slds-input-has-icon--right">' +
                  '    <svg class="slds-input__icon slds-icon-text-default">' +
                  '        <use xlink:href="{{getIconURL()}}"></use>' +
                  '    </svg>' +
                  '    <input class="slds-input" type="text" ng-model="label" ng-keyup="checkClearValue($event)" ng-focus="showList = true" ng-blur="showList = false"/>' +
                  '    <div ng-show="showList && options.length > 0" class="slds-lookup__menu" role="listbox">' +
                  '        <ul class="slds-lookup__list" role="presentation">' +
                  '            <li class="slds-lookup__item" ng-repeat="option in options" ng-mousedown="optionSelected(option)"><a role="option">{{option.label}}</a></li>' +
                  '        </ul>' +
                  '    </div>' +
                  '</div>',
        link: function(scope, element, attrs) {
            scope.showList = false;

            scope.getIconURL = function() {
                return SYMBOLS_URL + (scope.value == null || scope.value == '' ? '#search' : '#check');
            }

            scope.checkClearValue = function(event) {
                //Not tab(9), enter(13), shift(16), ctrl(17), end(35), home(36), left(37), up(38), right(39), down(40)
                if(event.keyCode != 9 && event.keyCode != 13 && event.keyCode != 16 && event.keyCode != 17 && !(event.keyCode >= 35 && event.keyCode <= 40))
                    scope.value = null;
            }

            scope.optionSelected = function(option) {
                scope.value = option.value;
                scope.label = option.label;
                scope.showList = false;
            }
        }
    }
});


// --( ss-drag Directive )--
SurveyBuilder.directive('ssDrag', function() {
    return {
        restrict: 'A', //Attributes only
        link: function(scope, element, attrs) {
            element.attr('draggable', 'true');
            element.on('dragstart', function(e) {
                element.addClass('drag');
                e.dataTransfer.setData('Text', angular.toJson(scope.$eval(attrs.ssDrag)));
            });
            element.on('dragend', function(e) {
                this.classList.remove('drag');
            });
        }
    };
});


// --( ss-drop Directive )--
SurveyBuilder.directive('ssDrop', function() {
    return {
        restrict: 'A', //Attributes only
        link: function(scope, element, attrs) {
            element.on('dragenter', function(e) {
                this.classList.add('over');
                e.preventDefault(); //Allow drop
            });
            element.on('dragleave', function(e) {
                this.classList.remove('over');
            });
            element.on('dragover', function(e) {
                this.classList.add('over');
                e.preventDefault(); //Allow drop
            });
            element.on('drop', function(e){
                e.preventDefault(); //Prevent navigation on Firefox

                scope.$apply(function() {
                    scope[attrs.ssDrop](scope, angular.fromJson(e.dataTransfer.getData('Text')));
                });

                [].forEach.call(document.querySelectorAll('[ss-drop]'), function(dropZone) {
                    dropZone.classList.remove('over');
                });
            });
        }
    };
});
