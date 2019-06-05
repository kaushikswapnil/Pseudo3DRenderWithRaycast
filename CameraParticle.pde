class CameraParticle extends Particle
{
  float m_FieldOfView;
  PVector m_Heading;
  
  CameraParticle(PVector heading, float posX, float posY, float radius, float fieldOfView, int numRaysPerRadianSlice)
  {
      super(posX, posY, radius);
      m_Heading = heading;
      m_FieldOfView = Limit(fieldOfView, 0, TWO_PI);
      
      CreateRays(numRaysPerRadianSlice);
  }
  
  void CreateRays(int numRaysPerRadianSlice)
  {
    m_Rays.clear();
    
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
  
  void ChangeFOV(float theta)
  {    
    float newFOV = m_FieldOfView + theta;
    newFOV = Limit(newFOV, 0, TWO_PI);
     //<>//
    if (!IsEqualWithEpsilon(newFOV, m_FieldOfView)) //<>//
    {
      theta = newFOV - m_FieldOfView;
      
      m_Heading.rotate(theta/2);
      
      int numRaysPerRadianSlice = (int)(m_Rays.size()/ m_FieldOfView);
      m_FieldOfView = newFOV;
      CreateRays(numRaysPerRadianSlice);
    }
  }
  
  void Rotate(float theta)
  { //<>//
    m_Heading.rotate(theta); //<>//

    int numRaysPerRadianSlice = (int)(m_Rays.size()/ m_FieldOfView);
    CreateRays(numRaysPerRadianSlice);
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
      
      float maxScreen1Dimension = max(screen1Width, screen1Height);
      
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
         else
         {
            scene[iter] = maxScreen1Dimension; //Think infinity 
         }
      }
     
      float minScreen1Dimension = min(screen1Width, screen1Height);
      float sliceWidth = screen2Width/scene.length;
      
      for (int sceneIter = 0; sceneIter < scene.length; ++sceneIter)
      {
         float objDist = scene[sceneIter];
         float objHeight = map(objDist, 0, maxScreen1Dimension, wallHeight, 0);
         float posX = map(sceneIter, 0, scene.length, screen1Width, screen1Width + screen2Width);
         
         float alpha = map(objDist*objDist, 0, minScreen1Dimension*minScreen1Dimension, 200, 0);
         
         rectMode(CENTER);
         
         noStroke();
         fill(255, alpha);
         rect(posX, screen2Height/2, sliceWidth + 1, objHeight);
      }
  }
}
