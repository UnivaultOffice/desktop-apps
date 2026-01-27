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

#include "ceventdriver.h"
#include "cascapplicationmanagerwrapper.h"


CEventDriver::CEventDriver(QObject *parent)
    : QObject(parent)
{

}

//void CEventDriver::signal(edEventType t)
//{
//    switch (t) {
//    case edEventType::etModalOpen:
//    case edEventType::etModalClose:
////        emit onModalDialog(t == edEventType::etModalOpen);
//        break;
//    default: break;
//    }
//}

void CEventDriver::signal(CInAppEventBase * e)
{
    switch (e->type()) {
    case CInAppEventBase::CEventType::etModal: {
        const CInAppEventModal & _e = static_cast<const CInAppEventModal &>(*e);
        emit onModalDialog(!_e.finished(), _e.handle());
        break; }
    case CInAppEventBase::CEventType::etEditorClosed:
        emit onEditorClosed();
        break;
    default: break;
    }
}

CRunningEventHelper::CRunningEventHelper(CInAppRunnigEvent * e)
    : m_event(e)
{
    AscAppManager::getInstance().commonEvents().signal(m_event);
}

CRunningEventHelper::~CRunningEventHelper()
{
    m_event->setFinished(true);
    AscAppManager::getInstance().commonEvents().signal(m_event);
}
