require 'spec_helper'

describe PhotosController do
  fixtures :photos

  context "an anon user" do
    let(:public_photo) { photos(:public_photo) }

    it "sees the list of published people" do
      get :index
      assert_template :index
      assigns(:photos).should == [public_photo]
    end

    it "sees a published photo" do
      get :show, id: 'a-public-photo'
      assert_template :show
      assigns(:photo).should == public_photo
    end

    it "doesn't see an unpublished photo" do
      get :show, id: 'a-private-photo'
      response.should redirect_to('/')
      flash[:alert].should == "You are not authorized to access this page."
    end
  end

  context "a normal user" do
    it "still doesn't see an unpublished photo" do
      sign_in create(:user)
      get :show, id: 'a-private-photo'
      response.should redirect_to('/')
      flash[:alert].should == "You are not authorized to access this page."
    end
  end

  context "an admin" do
    let(:public_photo) { photos(:public_photo) }
    let(:private_photo) { photos(:private_photo) }

    before do
      sign_in create(:admin)
    end

    it "sees the list of all photos (even unpublished)" do
      get :index
      assert_template :index
      assigns(:photos).should =~ [public_photo, private_photo]
    end

    it "sees an unpublished photo" do
      get :show, id: 'a-private-photo'
      assert_template :show
      assigns(:photo).should == private_photo
    end
  end
end
