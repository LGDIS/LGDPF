# encoding: utf-8


require 'spec_helper'


describe PhotoUrlUploader do

  include_context "carrier_wave_context"

  let(:testfile_240x320_jpg) { File.join Rails.root, 'spec', 'fixtures', 'testdata', 'IMG_1139.JPG' }
  let(:testfile_715x536_png) { File.join Rails.root, 'spec', 'fixtures', 'testdata', '715x536.png' }

  before do
    @person    = FactoryGirl.create(:person)
    @uploader1 = described_class.new(@person, :photo_url)
    @uploader2 = described_class.new(@person, :photo_url)
    @uploader1.store!(File.open(testfile_240x320_jpg))
    @uploader2.store!(File.open(testfile_715x536_png))
  end

  context "versions" do
    subject { @uploader1.versions }
    it { should include :mobile_small }
    it { should include :mobile_medium }
    it { should include :mobile_large }
  end

  context "mobile_small version" do
    subject { [@uploader1,@uploader2].map(&:mobile_small) }
    it "should scale down a landscape image to fit within 160 by 160 pixels" do
      [@uploader1,@uploader2].map(&:mobile_small).each do |uploader|
        uploader.should be_no_larger_than(160, 160)
      end
    end
    context "for example," do
      context "original:240x320" do
        subject { @uploader1.mobile_small }
        it { should have_dimensions(120, 160) }
        its(:to_s) { should =~ /\.jpg$/  }
        it { MIME::Types.type_for(subject.to_s)[0].should == "image/jpeg" }
      end
      context "original:715x536" do
        subject { @uploader2.mobile_small }
        it { should have_dimensions(160, 120) }
        its(:to_s) { should =~ /\.jpg$/  }
        it { MIME::Types.type_for(subject.to_s)[0].should == "image/jpeg" }
      end
    end
  end

  context "mobile_medium version" do
    subject { [@uploader1,@uploader2].map(&:mobile_medium) }
    it "should scale down a landscape image to fit within 160 by 160 pixels" do
      [@uploader1,@uploader2].map(&:mobile_medium).each do |uploader|
        uploader.should be_no_larger_than(230, 230)
      end
    end
    context "for example," do
      context "original:240x320" do
        subject { @uploader1.mobile_medium }
        it { should have_dimensions(173, 230) }
        its(:to_s) { should =~ /\.jpg$/  }
        it { MIME::Types.type_for(subject.to_s)[0].should == "image/jpeg" }
      end
      context "original:715x536" do
        subject { @uploader2.mobile_medium }
        it { should have_dimensions(230, 172) }
        its(:to_s) { should =~ /\.jpg$/  }
        it { MIME::Types.type_for(subject.to_s)[0].should == "image/jpeg" }
      end
    end
  end

  context "mobile_large version" do
    subject { [@uploader1,@uploader2].map(&:mobile_large) }
    it "should scale down a landscape image to fit within 480 by 480 pixels" do
      [@uploader1,@uploader2].map(&:mobile_large).each do |uploader|
        uploader.should be_no_larger_than(480, 480)
      end
    end
    context "for example," do
      context "original:240x320" do
        subject { @uploader1.mobile_large }
        it { should have_dimensions(240, 320) }
        its(:to_s) { should =~ /\.jpg$/  }
        it { MIME::Types.type_for(subject.to_s)[0].should == "image/jpeg" }
      end
      context "original:715x536" do
        subject { @uploader2.mobile_large }
        it { should have_dimensions(480, 360) }
        its(:to_s) { should =~ /\.jpg$/  }
        it { MIME::Types.type_for(subject.to_s)[0].should == "image/jpeg" }
      end
    end
  end


  after do
    [@uploader1,@uploader2].map(&:remove!)
  end

end
