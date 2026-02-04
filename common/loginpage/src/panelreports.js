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
                <div class="content-box reports-panel">
                    <div class="reports-header">
                        <h3 class="table-caption" l10n>${_lang.actReports}</h3>
                        <div class="reports-actions">
                            <div class="search-container">
                                <div class="icon-box">
                                    <svg class="icon search-icon" data-iconname="search" data-precls="tool-icon">
                                        <use href="#search"></use>
                                    </svg>
                                </div>
                                <input type="text" id="reports-search" placeholder="${_lang.reportsSearch}">
                                <span class="tool close" id="reports-search-clear" style="display: none;"></span>
                            </div>
                            <button id="reports-settings" class="btn btn--big" l10n>${_lang.reportsSettings}</button>
                            <button id="reports-create" class="btn btn--primary btn--big" l10n>${_lang.reportsCreate}</button>
                        </div>
                    </div>
                    <div class="reports-body">
                        <div id="reports-empty" class="reports-empty hidden">
                            <h4 l10n>${_lang.reportsEmptyTitle}</h4>
                            <p class="text-normal" l10n>${_lang.reportsEmptyText}</p>
                        </div>
                        <div id="reports-list" class="reports-list"></div>
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

                const STORAGE_KEY = 'reports_templates';
                let selectedId = null;
                const $panel = this.view.$panel;
                const $list = $panel.find('#reports-list');
                const $empty = $panel.find('#reports-empty');
                const $search = $panel.find('#reports-search');
                const $searchClear = $panel.find('#reports-search-clear');

                const loadTemplates = () => {
                    try {
                        const raw = localStorage.getItem(STORAGE_KEY);
                        const items = raw ? JSON.parse(raw) : [];
                        return Array.isArray(items) ? items : [];
                    } catch (e) {
                        return [];
                    }
                };

                const renderList = (items) => {
                    $list.empty();
                    if (!items.length) {
                        $empty.removeClass('hidden');
                        return;
                    }
                    $empty.addClass('hidden');
                    items.forEach(item => {
                        const id = item.id || item.uid || utils.fn.uuid();
                        const name = item.name || _lang.reportsUnnamed;
                        const descr = item.descr || '';
                        const updated = item.updated || '';

                        const $card = $(`
                            <div class="reports-card" data-id="${id}">
                                <div class="reports-card-head">
                                    <div class="reports-card-title">${name}</div>
                                </div>
                                <div class="reports-card-body text-normal">${descr}</div>
                                <div class="reports-card-meta text-normal">${updated}</div>
                                <div class="reports-card-actions">
                                    <button class="btn btn--primary btn--small" data-action="fill" l10n>${_lang.reportsFill}</button>
                                </div>
                            </div>
                        `);
                        $list.append($card);
                    });
                };

                const applySearch = () => {
                    const term = ($search.val() || '').trim().toLowerCase();
                    $searchClear.toggle(term.length > 0);
                    const items = loadTemplates().filter(t => {
                        const name = (t.name || '').toLowerCase();
                        const descr = (t.descr || '').toLowerCase();
                        return !term || name.includes(term) || descr.includes(term);
                    });
                    renderList(items);
                };

                $panel.on('click', '.reports-card', (e) => {
                    const $card = $(e.currentTarget);
                    $panel.find('.reports-card').removeClass('selected');
                    $card.addClass('selected');
                    selectedId = $card.data('id');
                });

                $panel.on('click', '[data-action="fill"]', (e) => {
                    e.stopPropagation();
                    const $card = $(e.currentTarget).closest('.reports-card');
                    const id = $card.data('id');
                    CommonEvents.fire('reports:create', [id]);
                    if (window.sdk && typeof window.sdk.execCommand === 'function') {
                        window.sdk.execCommand('reports:create', JSON.stringify({id}));
                    }
                });

                $panel.find('#reports-settings').on('click', () => {
                    CommonEvents.fire('reports:settings');
                    if (window.sdk && typeof window.sdk.execCommand === 'function') {
                        window.sdk.execCommand('reports:settings', '');
                    }
                });

                $panel.find('#reports-create').on('click', () => {
                    const id = selectedId;
                    if (!id) {
                        const dlg = new Dialog({
                            dialogClass: 'dlg-reports',
                            titleText: _lang.actReports,
                            defaultWidth: 420,
                            bodyTemplate: `<div class="text-normal">${_lang.reportsSelectTemplate}</div>`
                        });
                        dlg.show();
                        return;
                    }
                    CommonEvents.fire('reports:create', [id]);
                    if (window.sdk && typeof window.sdk.execCommand === 'function') {
                        window.sdk.execCommand('reports:create', JSON.stringify({id}));
                    }
                });

                $search.on('input', applySearch);
                $searchClear.on('click', () => {
                    $search.val('');
                    applySearch();
                });

                applySearch();

                return this;
            }
        };
    })());

    window.ControllerReports = ControllerReports;
}();
