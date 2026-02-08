/*
 * (c) Copyright Univault Technologies 2026-2026
 *
 * This program is a free software product. You can redistribute it and/or
 * modify it under the terms of the GNU Affero General Public License (AGPL)
 * version 3 as published by the Free Software Foundation. In accordance with
 * Section 7(a) of the GNU AGPL its Section 15 shall be amended to the effect
 * that Univault Technologies expressly excludes the warranty of non-infringement
 * of any third-party rights.
 *
 * This program is distributed WITHOUT ANY WARRANTY; without even the implied
 * warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR  PURPOSE. For
 * details, see the GNU AGPL at: http://www.gnu.org/licenses/agpl-3.0.html
 *
 * You can contact Univault Technologies at 0, bldg. 0, office 0 (TEST) Test Legal Street (TEST)
 * street, Moscow (TEST), Russia (TEST), EU, 000000 (TEST).
 *
 * The  interactive user interfaces in modified source and object code versions
 * of the Program must display Appropriate Legal Notices, as required under
 * Section 5 of the GNU AGPL version 3.
 *
 * Pursuant to Section 7(b) of the License you must retain the original Product
 * logo when distributing the program. Pursuant to Section 7(e) we decline to
 * grant you any rights under trademark law for use of our trademarks.
 *
 * All the Product's GUI elements, including illustrations and icon sets, as
 * well as technical writing content are licensed under the terms of the
 * Creative Commons Attribution-ShareAlike 4.0 International. See the License
 * terms at http://creativecommons.org/licenses/by-sa/4.0/legalcode
 *
*/

+function(){ 'use strict'
    var ControllerReports = function(args={}) {
        args.caption = 'Reports';
        args.action =
        this.action = "reports";
        this.view = new ViewReports(args);
    };

    ControllerReports.prototype = Object.create(baseController.prototype);
    ControllerReports.prototype.constructor = ControllerReports;

    var ViewReports = function(args) {
        var _lang = utils.Lang;

        args.tplPage = `
            <div class="action-panel ${args.action}">
                <div class="reports-panel">
                    <iframe id="reports-iframe" class="reports-iframe" src="about:blank" allow="clipboard-read; clipboard-write"></iframe>
                    <div id="reports-missing" class="reports-missing hidden">
                        <h3 class="table-caption" l10n>${_lang.reportsMissingTitle}</h3>
                        <p class="text-normal" l10n>${_lang.reportsMissingText}</p>
                    </div>
                </div>
            </div>`;
        args.menu = '.main-column.tool-menu';
        args.field = '.main-column.col-center';
        args.itemindex = 0;
        args.tplItem = 'nomenuitem';

        baseView.prototype.constructor.call(this, args);
    };

    ViewReports.prototype = Object.create(baseView.prototype);
    ViewReports.prototype.constructor = ViewReports;

    utils.fn.extend(ControllerReports.prototype, (() => {
        return {
            init: function() {
                baseController.prototype.init.apply(this, arguments);
                this.view.render();

                const $panel = this.view.$panel;
                const $iframe = $panel.find('#reports-iframe');
                const $missing = $panel.find('#reports-missing');

                const fileUrlFromPath = (path) => {
                    if (!path) return 'about:blank';
                    let p = path.replace(/\\/g, '/');
                    if (/^[a-zA-Z]:/.test(p)) {
                        p = 'file:///' + p;
                    }
                    return encodeURI(p);
                };

                const postToIframe = (message) => {
                    try {
                        const iframe = $iframe[0];
                        if (iframe && iframe.contentWindow) {
                            iframe.contentWindow.postMessage(JSON.stringify(message), '*');
                        }
                    } catch (e) {
                        // ignore
                    }
                };

                const getLangId = () => {
                    return (utils.Lang && utils.Lang.id) ? utils.Lang.id : 'en';
                };

                const getLocaleDict = () => {
                    const lang = utils.Lang || {};
                    return {
                        title: lang.actReports || 'Reports',
                        create: lang.reportsCreate || lang.actCreateNew || 'Create',
                        settings: lang.reportsSettings || lang.actSettings || 'Settings',
                        search: lang.reportsSearch || 'Search reports',
                        empty_title: lang.reportsEmptyTitle || 'No templates yet',
                        empty_text: lang.reportsEmptyText || 'Add a template in settings to start generating reports.',
                        fill: lang.reportsFill || 'Fill',
                        untitled: lang.reportsUnnamed || 'Untitled'
                    };
                };

                const postLocale = (langId) => {
                    postToIframe({event:'uiLocaleChanged', data: {lang: langId, dict: getLocaleDict()}});
                };

                const setRoot = (root) => {
                    if (!root) {
                        $missing.removeClass('hidden');
                        $iframe.attr('src', 'about:blank');
                        return;
                    }
                    $missing.addClass('hidden');
                    const lang = encodeURIComponent(getLangId());
                    const src = fileUrlFromPath(`${root}/reports-ui/index.html`) + `?lang=${lang}`;
                    $iframe.attr('src', src);
                };

                setRoot(window.reportsUiRoot || null);
                CommonEvents.on('reports:root', (root) => setRoot(root));
                CommonEvents.on('lang:changed', (prev, next) => {
                    postToIframe({event:'uiLangChanged', data: {new: next, old: prev}});
                    postLocale(next);
                });
                CommonEvents.on('theme:changed', (name, type) => {
                    postToIframe({event:'uiThemeChanged', data: {name: name, type: type}});
                });

                $iframe.on('load', () => {
                    postToIframe({event:'uiLangChanged', data: {new: getLangId()}});
                    postLocale(getLangId());
                    postToIframe({event:'uiThemeChanged', data: {name: null}});
                });

                const parseMessage = (payload) => {
                    try {
                        return (typeof payload === 'string') ? JSON.parse(payload) : payload;
                    } catch (e) {
                        return null;
                    }
                };

                const buildRunScript = (job, debug) => {
                    const jobStr = JSON.stringify(job || {});
                    const debugFlag = debug ? 'true' : 'false';
                    return `function(){try{var job=JSON.parse(${JSON.stringify(jobStr)});var st=window.__reportsState||(window.__reportsState={});if(st.lastJobId===job.id&&st.done)return;st.lastJobId=job.id;st.job=job;st.done=false;st.debug=${debugFlag};st.startedAt=Date.now();var api=(window.Asc&&Asc.editor)?Asc.editor:(window.editor||window.Asc);if(!api||!api.asc_getDocumentName)return;function ready(){var full=api.isLoadFullApi;var loaded=api.isDocumentLoadComplete;try{if(typeof full==='function')full=full.call(api);}catch(e){}try{if(typeof loaded==='function')loaded=loaded.call(api);}catch(e){}return !!(full&&loaded);}function setRange(sheet,addr){var a=String(addr||'').trim();if(!a)return;var s=String(sheet||'').trim();var full=s?(s+'!'+a):a;api.asc_setWorksheetRange(full);}function insertText(val){var text=String(val||'');if(api.asc_insertInCell){api.asc_insertInCell(text);if(api.asc_closeCellEditor)api.asc_closeCellEditor();return;}if(api.asc_enterText){var v=text;try{v=(v&&v.codePointsArray)?v.codePointsArray():v;}catch(e){}api.asc_enterText(v);if(api.asc_closeCellEditor)api.asc_closeCellEditor();}}function run(){if(!ready())return false;var acts=st.job&&st.job.actions?st.job.actions:[];if(st.debug){try{setRange('', 'Z1');insertText('REPORTS DEBUG '+(st.job.id||''));}catch(e){}}function runAction(action){if(!action||!action.type)return;if(action.type==='setText'){var target=String(action.target||'').trim();if(!target)return;setRange(action.sheet,target);insertText(action.value||'');if(action.merge){try{api.asc_mergeCells();}catch(e){}}}else if(action.type==='groupCols'){if(!action.range)return;setRange(action.sheet,action.range);api.asc_group(false);if(typeof action.expanded==='boolean'){try{api.asc_changeGroupDetails(!!action.expanded);}catch(e){}}}else if(action.type==='deleteRow'){if(!action.row)return;var row=String(action.row).trim();if(!row)return;setRange(action.sheet,row+':'+row);api.asc_deleteCells(Asc.c_oAscDeleteOptions.DeleteRows);}}for(var i=0;i<acts.length;i++){runAction(acts[i]);}st.done=true;return true;}if(run())return;if(st.timer){clearInterval(st.timer);st.timer=null;}st.timer=setInterval(function(){try{if(run()){clearInterval(st.timer);st.timer=null;}else if(Date.now()-st.startedAt>60000){clearInterval(st.timer);st.timer=null;}}catch(e){}},500);}catch(e){}}`;
                };

                const runJob = (payload) => {
                    if (!payload) return;
                    const job = payload.job || {};
                    const templateId = payload.templateId || job.templateId || null;
                    try {
                        if (window.sdk && payload.path) {
                            window.sdk.command('create:new', JSON.stringify({
                                template: {
                                    id: templateId,
                                    type: payload.typeId || 0,
                                    path: payload.path
                                }
                            }));
                        }
                    } catch (e) {
                        // ignore
                    }
                    if (!window.AscDesktopEditor || !window.AscDesktopEditor.CallInAllWindows)
                        return;

                    const script = buildRunScript(job, !!payload.debug);
                    const sendScript = () => {
                        try {
                            if (typeof script === 'string') {
                                window.AscDesktopEditor.CallInAllWindows(script);
                            }
                        } catch (e) {
                            // ignore
                        }
                    };

                    sendScript();
                    const start = Date.now();
                    const timer = setInterval(() => {
                        sendScript();
                        if (Date.now() - start > 60000) {
                            clearInterval(timer);
                        }
                    }, 1000);
                };

                window.addEventListener('message', (evt) => {
                    const msg = parseMessage(evt.data);
                    if (!msg || msg.event !== 'reportsRun' || msg.source !== 'reports-ui')
                        return;
                    runJob(msg.data);
                }, false);

                return this;
            }
        };
    })());

    window.ControllerReports = ControllerReports;
}();
