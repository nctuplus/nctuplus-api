require 'rails_helper'

RSpec.describe CommentsController, type: :controller do
  let(:valid_attributes) do
    FactoryBot.attributes_for :comment_for_rspec_test
  end

  let!(:rating) do
    3.times.map { rand(4) + 1 }.join.to_s
  end

  let(:invalid_attributes) do
    FactoryBot.attributes_for :comment_for_rspec_test, title: nil
  end

  let(:new_attribute) {{ title: 'I am loser.' }}

  let(:invalid_new_attribute) {{ title: nil }}

  let(:current_user) do
    FactoryBot.create :user
  end

  let(:auth_token) do
    current_user.create_new_auth_token
  end

  describe 'GET #index' do
    it 'returns a success response' do
      Comment.create valid_attributes
      get :index, params: {}
      expect(response).to be_successful
    end
  end

  describe 'GET #show' do
    it 'returns a success response' do
      comment = Comment.create valid_attributes
      get :show, params: { id: comment.to_param }
      expect(response).to be_successful
    end
  end

  describe 'POST #create' do
    before(:each) do
      request.headers.merge! auth_token
    end

    context 'with valid attributes' do
      it 'creates a new comment' do
        expect do
          post :create, params: { comment: valid_attributes, rating: rating, course: { id: valid_attributes[:course].id } }
        end.to change(Comment, :count).by(1)
      end

      it 'renders a json response with the new comment' do
        post :create, params: { comment: valid_attributes, rating: rating, course: { id: valid_attributes[:course].id } }
        expect(response).to have_http_status(:created)
        expect(response.content_type).to eq('application/json')
        expect(response.location).to eq(comment_url(Comment.last))
      end
    end

    context 'with invalid_attributes' do
      it 'renders a JSON response with errors for new comment' do
        post :create,
          params: { comment: invalid_attributes, rating: rating, course: { id: invalid_attributes[:course].id } }
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to eq('application/json')
      end

      it 'does not create a new comment' do
        expect do
          post :create,
            params: { comment: invalid_attributes, rating: rating, course: { id: invalid_attributes[:course].id } }
        end.to change(Comment, :count).by(0)
      end
    end

    context 'with no related course specified' do
      it 'returns with status code unprocessable_entity' do
        post :create, params: { comment: invalid_new_attribute, rating: rating }
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'does not create a new comment' do
        expect do
          post :create, params: { comment: invalid_new_attribute, rating: rating }
        end.to change(Comment, :count).by(0)
      end
    end

    context 'the same comment is already existed' do
      it 'returns with status code ok' do
        comment = Comment.create valid_attributes
        comment.update user: current_user
        post :create, params: { comment: valid_attributes, rating: rating, course: { id: comment.course_id } }
        expect(response).to have_http_status(:ok)
      end

      it 'does not create a new comment' do
        comment = Comment.create valid_attributes
        comment.update user: current_user
        expect do
          post :create, params: { comment: valid_attributes, rating: rating, course: { id: comment.course_id } }
        end.to change(Comment, :count).by(0)
      end
    end
  end

  describe 'PATCH #update' do
    before(:each) do
      request.headers.merge! auth_token
    end

    context 'with valid attributes' do
      it 'updates the requested comment' do
        comment = Comment.create valid_attributes
        comment.update user: current_user
        patch :update, params: { id: comment.to_param, comment: new_attribute }
        comment.reload
        expect(comment.title).to eq('I am loser.')
      end

      it 'renders a json response with the requested comment' do
        comment = Comment.create valid_attributes
        comment.update user: current_user
        patch :update, params: { id: comment.to_param, comment: new_attribute }
        expect(response).to have_http_status(:ok)
        expect(response.content_type).to eq('application/json')
      end
    end

    context 'with invalid attributes' do
      it 'does not update the requested comment' do
        comment = Comment.create valid_attributes
        comment.update user: current_user
        original_title = comment.title
        patch :update, params: { id: comment.to_param, comment: invalid_new_attribute }
        comment.reload
        expect(comment.title).to eq(original_title)
      end

      it 'returns with status code unprocessable_entity' do
        comment = Comment.create valid_attributes
        comment.update user: current_user
        patch :update, params: { id: comment.to_param, comment: invalid_new_attribute }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'DELETE #destroy' do
    before(:each) do
      request.headers.merge! auth_token
    end

    context 'current user is the creator of the requested comment' do
      it 'destroys the requested comment' do
        comment = Comment.create valid_attributes
        comment.update user: current_user
        expect do
          delete :destroy, params: { id: comment.to_param }
        end.to change(Comment, :count).by(-1)
      end
    end

    context 'current user is not the creator of requested comment' do
      it 'does not destroy the requested comment' do
        comment = Comment.create valid_attributes
        comment.update user: FactoryBot.create(:user)
        expect do
          delete :destroy, params: { id: comment.to_param }
        end.to change(Comment, :count).by(0)
      end

      it 'returns with response code 401'do
        comment = Comment.create valid_attributes
        comment.update user: FactoryBot.create(:user)
        delete :destroy, params: { id: comment.to_param }
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
