class Particle
{
   PVector m_Position;
   float m_Radius;
   
   ArrayList<Ray> m_Rays;
   
   Particle(float posX, float posY, float radius) //for derived class calls
   {
     m_Position = new PVector(posX, posY);
     m_Radius = radius;
     
     m_Rays = new ArrayList<Ray>();
   }
   
   Particle(float posX, float posY, float radius, int numRays)
   {
     m_Position = new PVector(posX, posY);
     m_Radius = radius;
     
     m_Rays = new ArrayList<Ray>();
     
     float angleIncrement = TWO_PI/numRays;
     
     for(float iter = 0; iter < TWO_PI; iter += angleIncrement)
     {
        m_Rays.add(new Ray(m_Position, PVector.fromAngle(iter))); 
     }
   }
   
   void Display()
   {
      stroke(255);
      fill(255);
      ellipse(m_Position.x, m_Position.y, m_Radius, m_Radius);
   }
   
   void UpdatePos()
   {
      m_Position.x = Limit(mouseX, 0, screen1Width);
      m_Position.y = Limit(mouseY, 0, screen1Height);
      
      for (Ray ray : m_Rays)
      {
         ray.m_StartPos.x = m_Position.x;
         ray.m_StartPos.y = m_Position.y;
      }
   }
   
   void Update(ArrayList<Shape> shapes)
   {
      UpdatePos();
     
      Display(); 
     
      ContactPoint testContactPoint = new ContactPoint(0, 0);
      for (Ray ray : m_Rays)
      {
         if (ray.Cast(shapes, testContactPoint))
         {
           stroke(255, 120);
           //point(testContactPoint.m_Position.x, testContactPoint.m_Position.y);
           line(m_Position.x, m_Position.y, testContactPoint.m_Position.x, testContactPoint.m_Position.y);
         }
      }
   }
}

class CameraParticle extends Particle
{
  float m_FieldOfView;
  PVector m_Heading;
  
  CameraParticle(PVector heading, float posX, float posY, float radius, float fieldOfView, int numRaysPerRadianSlice)
  {
      super(posX, posY, radius);
      m_Heading = heading;
      m_FieldOfView = Limit(fieldOfView, 0, TWO_PI);
      int numRays = (int)(m_FieldOfView * numRaysPerRadianSlice);
      
      float angleIncrement = 1.0f/numRaysPerRadianSlice;
      
      float minAngle = m_Heading.heading() - (m_FieldOfView/2);
      float maxAngle = m_Heading.heading() + (m_FieldOfView/2);
      
      float angle = minAngle;
      
      while(IsLesserOrEqualWithEpsilon(angle, maxAngle))
      {
         m_Rays.add(new Ray(m_Position, PVector.fromAngle(angle)));
        
         angle += angleIncrement; 
      }
  }
  
  void Update(ArrayList<Shape> shapes)
  {
    DrawSceneAndDrawSelf(shapes);
  }
  
  void DrawSceneAndDrawSelf(ArrayList<Shape> shapes) //Horrible naming, I know
  {
      UpdatePos();
     
      Display(); 
      
      float[] scene = new float[m_Rays.size()];
      
      ContactPoint testContactPoint = new ContactPoint(0, 0);
      
      for (int iter = 0; iter < m_Rays.size(); ++iter)
      {
         Ray ray = m_Rays.get(iter);
         
         if (ray.Cast(shapes, testContactPoint))
         {
           stroke(255, 120);
           //point(testContactPoint.m_Position.x, testContactPoint.m_Position.y);
           line(m_Position.x, m_Position.y, testContactPoint.m_Position.x, testContactPoint.m_Position.y);
           PVector contactPointRelToPos = PVector.sub(testContactPoint.m_Position, m_Position);
           
           float contactPointProjectedOnHeading = PVector.dot(contactPointRelToPos, m_Heading);
           
           scene[iter] = contactPointProjectedOnHeading;
           //Produces fish eye effect
           //scene[iter] = PVector.dist(m_Position, testContactPoint.m_Position);
         }
      }
      
      float maxScreen1Dimension = max(screen1Width, screen1Height);
      float minScreen1Dimension = min(screen1Width, screen1Height);
      
      for (int sceneIter = 0; sceneIter < scene.length; ++sceneIter)
      {
         float objDist = scene[sceneIter];
         float objHeight = map(objDist, 0, maxScreen1Dimension, wallHeight, 0);
         float posX = map(sceneIter, 0, scene.length, screen1Width, screen1Width + screen2Width);
         
         float alpha = map(objDist*objDist, 0, minScreen1Dimension*minScreen1Dimension, 200, 0);
         
         rectMode(CENTER);
         
         noStroke();
         fill(255, alpha);
         rect(posX, screen2Height/2, screen2Width/scene.length, objHeight);
      }
  }
}
