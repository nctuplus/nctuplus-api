require 'rails_helper'

RSpec.describe ReplyController, type: :controller do
  let(:valid_attributes) { FactoryBot.attributes_for :reply_for_rspec_test }
  let(:invalid_attributes) { FactoryBot.attributes_for :reply, content: nil }
  let(:new_attribute) { { content: 'I am loser.' } }
  let(:invalid_new_attribute) { { content: nil } }
  let(:current_user) { FactoryBot.create :user }
  let(:auth_token) { current_user.create_new_auth_token }
  let(:comment_id) do
    comment = FactoryBot.create :comment_for_rspec_test
    comment.id
  end

  describe 'POST #create' do
    before(:each) do
      request.headers.merge! auth_token
      request.headers['Content-Type'] = 'application/json'
    end

    context 'with valid attributes' do
      it 'creates a new reply' do
        expect do
          post :create, params: { reply: valid_attributes, comment_id: comment_id }
        end.to change(Reply, :count).by(1)
      end

      it 'creates a new non-anonymous reply' do
        post :create, params: { reply: valid_attributes, comment_id: comment_id, anonymity: false }
        expect(Reply.last.anonymity).to eq(false)
      end

      it 'returns with status code created' do
        post :create, params: { reply: valid_attributes, comment_id: comment_id }
        expect(response).to have_http_status(:created)
      end
    end

    context 'with invalid attributes' do
      it 'renders a JSON response with errors for new comment' do
        post :create, params: { reply: invalid_attributes, comment_id: comment_id }
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to eq('application/json')
      end
    end

    context 'with valid attributes but with non-existed comment_id' do
      it 'renders a JSON response with status code unprocessable_entity' do
        post :create, params: { reply: valid_attributes, comment_id: comment_id + 100 }
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to eq('application/json')
      end
    end
  end

  describe 'DELETE #destroy' do
    before(:each) do
      request.headers.merge! auth_token
    end

    context 'current user is the creator of the requested reply' do
      it 'it destroys the requested reply' do
        reply = Reply.create valid_attributes
        reply.update user: current_user
        expect do
          delete :destroy, params: { id: reply.to_param, comment_id: reply.comment.id }
        end.to change(Reply, :count).by(-1)
      end
    end

    context 'current user is not the creator of the requested reply' do
      it 'does not destroy the requested reply' do
        reply = Reply.create valid_attributes
        expect do
          delete :destroy, params: { id: reply.to_param, comment_id: reply.comment_id }
        end.to change(Reply, :count).by(0)
      end

      it 'renders with JSON response with status code unauthorized' do
        reply = Reply.create valid_attributes
        delete :destroy, params: { id: reply.to_param, comment_id: reply.comment_id }
        expect(response).to have_http_status(:unauthorized)
        expect(response.content_type).to eq('application/json')
      end
    end
  end
end
