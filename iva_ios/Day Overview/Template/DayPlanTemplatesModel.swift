//
//  DayPlanTemplatesModel.swift
//  iva_ios
//
//  Created by Igor Pidik on 15/05/2022.
//

import Foundation

class DayPlanTemplatesModel: ObservableObject {
    @Published var templates = [DayPlanTemplate]()
    
    init() {
        reloadTemplates()
    }
    
    func reloadTemplates() {
        IvaBackendClient.fetchDayPlanTemplates().done { result in
            self.templates = result
        }.catch { error in
            print(error)
        }
    }
    
    func saveTemplate(template: DayPlanTemplate) {
        IvaBackendClient.postDayPlanTemplate(template: template).done { _ in
            self.reloadTemplates()
        }.catch { err in
            print(err)
        }
    }
    
    func patchTemplate(template: DayPlanTemplate) {
        IvaBackendClient.patchDayPlanTemplate(template: template).done { _ in
            self.reloadTemplates()
        }.catch { err in
            print(err)
        }
    }
    
    func updateTemplateActivity(templateId: Int, activity: DayPlanTemplateActivity) {
        IvaBackendClient.patchDayPlanTemplateActivity(dayPlanTemplateId: templateId, activity: activity).done { _ in
            self.reloadTemplates()
        }.catch { err in
            print(err)
        }
    }
    
    func deleteTemplateActivity(templateId: Int, activity: DayPlanTemplateActivity) {
        IvaBackendClient.deleteDayPlanTemplateActivity(dayPlanTemplateId: templateId, activity: activity).done { _ in
            self.reloadTemplates()
        }.catch { err in
            print(err)
        }
    }
    
    func postTemplateActivity(templateId: Int, activity: DayPlanTemplateActivity) {
        IvaBackendClient.postDayPlanTemplateActivity(dayPlanTemplateId: templateId, activity: activity).done { _ in
            self.reloadTemplates()
        }.catch { err in
            print(err)
        }
    }
}
