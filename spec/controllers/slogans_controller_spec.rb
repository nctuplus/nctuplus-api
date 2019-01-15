require 'rails_helper'

RSpec.describe SlogansController, type: :controller do
  let(:valid_attributes) do
    FactoryBot.attributes_for :slogan
  end

  let(:invalid_attributes) do
    FactoryBot.attributes_for :slogan, display: nil
  end

  let(:current_user) do
    FactoryBot.create :user
  end

  describe 'GET #index' do
    it 'returns a success response' do
      Slogan.create! valid_attributes
      get :index, params: {}
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'GET #show' do
    it 'returns a success response' do
      slogan = Slogan.create! valid_attributes
      get :show, params: { id: slogan.to_param }
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'POST #create' do
    before(:each) do
      request.headers.merge! current_user.create_new_auth_token
    end
    context 'with valid params' do
      it 'create a new slogan' do
        expect do
          post :create, params: { slogan: valid_attributes }
        end.to change(Slogan, :count).by(1)
      end

      it 'renders a JSON response with the new slogan' do
        post :create, params: { slogan: valid_attributes }
        expect(response).to have_http_status(:created)
        expect(response.content_type).to eq('application/json')
      end
    end

    context 'with display is non boolean value' do
      it 'returns staus code 422' do
        post :create, params: { slogan: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'PUT #create' do
    before(:each) do
      request.headers.merge! current_user.create_new_auth_token
    end
    let(:new_attributes) {{ title: 'Hello Motorola' }}

    context 'with valid params' do
      it 'updates the requested slogan' do
        slogan = current_user.slogans.create! valid_attributes
        put :update, params: { id: slogan.to_param, slogan: new_attributes }
        slogan.reload
        expect(slogan.title).to eq('Hello Motorola')
      end

      it 'renders a JSON response with the slogan' do
        slogan = current_user.slogans.create! valid_attributes
        put :update, params: { id: slogan.to_param, slogan: new_attributes }
        expect(response).to have_http_status(:ok)
        expect(response.content_type).to eq('application/json')
      end
    end

    context 'with display filed is non-boolean value' do
      it 'will reutrn with status code 422, unprocessable_entity' do
        slogan = current_user.slogans.create! valid_attributes
        put :update, params: { id: slogan.to_param, slogan: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context 'with current user is not the slogan creator' do
      it 'will not update the requested slogan' do
        slogan = current_user.slogans.create! valid_attributes
        slogan.update(author: FactoryBot.create(:user))
        put :update, params: { id: slogan.to_param, slogan: new_attributes }
        slogan.reload
        expect(slogan.title).not_to eq('Hello Motorola')
      end

      it 'will render JSON response with 403 unauthorized status code' do
        slogan = current_user.slogans.create! valid_attributes
        slogan.update(author: FactoryBot.create(:user))
        put :update, params: { id: slogan.to_param, slogan: new_attributes }
        expect(response).to have_http_status(:unauthorized)
        expect(response.content_type).to eq('application/json')
      end
    end
  end

  describe 'DELETE #destroy' do
    before(:each) do
      request.headers.merge! current_user.create_new_auth_token
    end
    it 'destroys the requested slogan' do
      slogan = current_user.slogans.create! valid_attributes
      expect do
        delete :destroy, params: { id: slogan.to_param }
      end.to change(Slogan, :count).by(-1)
    end

    it 'will not destroy the requested slogan if current user is not the creator' do
      slogan = current_user.slogans.create! valid_attributes
      slogan.update(author: FactoryBot.create(:user))
      expect do
        delete :destroy, params: { id: slogan.to_param }
      end.to change(Slogan, :count).by(0)
    end

    it 'renders JSON response if current user is not the slogan creator' do
      slogan = current_user.slogans.create! valid_attributes
      slogan.update(author: FactoryBot.create(:user))
      delete :destroy, params: { id: slogan.to_param }
      expect(response).to have_http_status(:unauthorized)
      expect(response.content_type).to eq('application/json')
    end
  end
end
