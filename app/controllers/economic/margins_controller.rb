# coding: utf-8

# == License
# Ekylibre - Simple agricultural ERP
# Copyright (C) 2012-2015 David Joulin, Brice Texier
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
module Economic
  class MarginsController < Backend::BaseController
    include Rails.application.routes.url_helpers
    def index
    end

    def margins_xslx_export
      campaigns = Campaign.where(id: params[:campaign_id])
      activities = Activity.where(id: params[:activity_ids])
      if campaigns.any? and activities.any?
        notify_success(:document_in_preparation)
        filename = "#{:document_global_costs.tl}-#{campaigns.pluck(:name).to_sentence}.xslx"
        output_path = Ekylibre::Tenant.private_directory.join(filename)
        File.delete(output_path) if File.exist?(output_path)
        content = MarginsXslxExport.new.generate(activity_ids: activities.pluck(:id), campaign_ids: campaigns.pluck(:id))
        File.binwrite(output_path, content.read)
        send_file output_path, type: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
      else
        notify_error(:document_in_preparation)
      end
    end



  end
end
