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
                });
                CommonEvents.on('theme:changed', (name, type) => {
                    postToIframe({event:'uiThemeChanged', data: {name: name, type: type}});
                });

                $iframe.on('load', () => {
                    postToIframe({event:'uiLangChanged', data: {new: getLangId()}});
                    postToIframe({event:'uiThemeChanged', data: {name: null}});
                });

                return this;
            }
        };
    })());

    window.ControllerReports = ControllerReports;
}();
