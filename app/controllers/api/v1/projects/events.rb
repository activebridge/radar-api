# frozen_string_literal: true

class API::V1::Projects::Events < Grape::API
  helpers do
    def project
      @project ||= current_user.projects.find(params[:id])
    end

    def project_by_api_key
      binding.pry
      @project_by_api_key ||= Project.find_by(api_key: params[:project_id])
    end

    def events
      @events ||= project.events
    end

    def matched_event
      @matched_event ||= project.events.find(params[:id])
    end
  end

  namespace 'projects/:project_id' do
    resources :events do
      desc 'Returns events'
      get do
        status 200
        render(events)
      end

      desc 'Create event'
      params do
        requires :event, type: Hash do
          requires :status, type: Integer, values: Event.statuses.values
          requires :title, type: String
          requires :user_id, type: Integer
        end
      end

      post do
        return(status 401) unless project_by_api_key
        
        if project_by_api_key.events.create(declared_params[:event])
          status 201
          render(matched_event)
        else
          render_error(matched_event)
        end
      end

      desc 'Returns event'
      params do
        requires :id, type: String
      end

      get ':id' do
        status 200
        render(matched_event)
      end

      desc 'Updates event'
      params do
        requires :event, type: Hash do
          optional :status, type: Integer, values: Event.statuses.values
          optional :user_id, type: Integer
        end
      end

      patch ':id' do
        if matched_event.update(declared_params[:event])
          status 200
          render(matched_event)
        else
          render_error(matched_event)
        end
      end
    end
  end
end
