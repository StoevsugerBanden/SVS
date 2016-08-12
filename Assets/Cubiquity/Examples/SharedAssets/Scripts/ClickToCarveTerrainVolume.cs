﻿using UnityEngine;
using System.Collections;

using Cubiquity;

public class ClickToCarveTerrainVolume : MonoBehaviour
{
	private TerrainVolume terrainVolume;
    public int range = 10;
	
	// Bit of a hack - we want to detect mouse clicks rather than the mouse simply being down,
	// but we can't use OnMouseDown because the voxel terrain doesn't have a collider (the
	// individual pieces do, but not the parent). So we define a click as the mouse being down
	// but not being down on the previous frame. We'll fix this better in the future...
	private bool isMouseAlreadyDown = false;
	
	// Use this for initialization
	void Start ()
	{
		// We'll store a reference to the colored cubes volume so we can interact with it later.
		terrainVolume = gameObject.GetComponent<TerrainVolume>();
		if(terrainVolume == null)
		{
			Debug.LogError("This 'ClickToCarveTerrainVolume' script should be attached to a game object with a TerrainVolume component");
		}
	}
	
	// Update is called once per frame
	void Update ()
	{
		// Bail out if we're not attached to a terrain.
		if(terrainVolume == null)
		{
			return;
		}
		
		// If the mouse btton is down and it was not down last frame
		// then we consider this a click, and do our destruction.
		if(Input.GetMouseButton(0))
		{
			if(!isMouseAlreadyDown)
			{
				// Build a ray based on the current mouse position
				Vector2 mousePos = Input.mousePosition;
				Ray ray = Camera.main.ScreenPointToRay(new Vector3(mousePos.x, mousePos.y, 0));
                //print(mousePos + "" + Screen.width);				
				
				// Perform the raycasting.
				PickSurfaceResult pickResult;
				bool hit = Picking.PickSurface(terrainVolume, ray, 1000.0f, out pickResult);
				
				// If we hit a solid voxel then create an explosion at this point.
				if(hit)
				{
					DestroyVoxels((int)pickResult.volumeSpacePos.x, (int)pickResult.volumeSpacePos.y, (int)pickResult.volumeSpacePos.z, range);
				}
				
				// Set this flag so the click won't be processed again next frame.
				//isMouseAlreadyDown = true;
			}
		}
		else
		{
			// Clear the flag while we wait for a click.
			isMouseAlreadyDown = false;
		}
	}
	
	public void DestroyVoxels(int xPos, int yPos, int zPos, int range)
	{
        yPos += (int)(range+1);
		// Initialise outside the loop, but we'll use it later.
		int rangeSquared = range * range;
		MaterialSet emptyMaterialSet = new MaterialSet();
		
		// Iterage over every voxel in a cubic region defined by the received position (the center) and
		// the range. It is quite possible that this will be hundreds or even thousands of voxels.
		for(int z = zPos - range; z < zPos + range; z++) 
		{
			for(int y = yPos - range; y < yPos + range; y++)
			{
				for(int x = xPos - range; x < xPos + range; x++)
				{			
					// Compute the distance from the current voxel to the center of our explosion.
					int xDistance = x - xPos;
					int yDistance = y - yPos;
					int zDistance = z - zPos;
					
					// Working with squared distances avoids costly square root operations.
					int distSquared = xDistance * xDistance + yDistance * yDistance + zDistance * zDistance;
					
					// We're iterating over a cubic region, but we want our explosion to be spherical. Therefore 
					// we only further consider voxels which are within the required range of our explosion center. 
					// The corners of the cubic region we are iterating over will fail the following test.
					if(distSquared < rangeSquared)
					{	
						terrainVolume.data.SetVoxel(x, y, z, emptyMaterialSet);
					}
				}
			}
		}
		
		range += 2;
		
		TerrainVolumeEditor.BlurTerrainVolume(terrainVolume, new Region(xPos - range, yPos - range, zPos - range, xPos + range, yPos + range, zPos + range));
		//TerrainVolumeEditor.BlurTerrainVolume(terrainVolume, new Region(xPos - range, yPos - range, zPos - range, xPos + range, yPos + range, zPos + range));
		//TerrainVolumeEditor.BlurTerrainVolume(terrainVolume, new Region(xPos - range, yPos - range, zPos - range, xPos + range, yPos + range, zPos + range));
	}

    public void DestroyVoxels2(int xPos, int yPos, int zPos, int range)
    {
        yPos += (int)(range + 1);
        int rangeSquared = range * range;
        MaterialSet emptyMaterialSet = new MaterialSet();
        //Iterer over alle givne voxels, defineret af en range fra start positionen. Altså ikke alle voxels bliver
        //gennegået, men kun en "kasse" der bliver definere med range parametret. 
        for (int z = zPos - range; z < zPos + range; z++)
        {
            for (int y = yPos - range; y < yPos + range; y++)
            {
                for (int x = xPos - range; x < xPos + range; x++)
                {
                    //Find distancen fra den nuværende voxel til centrum
                    int xDistance = x - xPos;
                    int yDistance = y - yPos;
                    int zDistance = z - zPos;

                    // for at undgå dyre kvadratrodsudregninger kvadreteres distancerne. 
                    int distSquared = xDistance * xDistance + yDistance * yDistance + zDistance * zDistance;

                    //For at udviske voxels i en sphere i stedet for et kvadrat, tjekkes distancen fra den enkelte voxel til centrum, og hvis denne 
//er kortere end en radius defineret af range, udviskes disse. 
                    if (distSquared < rangeSquared)
                    {
                        terrainVolume.data.SetVoxel(x, y, z, emptyMaterialSet);
                    }
                }
            }
        }

        range += 2;

        TerrainVolumeEditor.BlurTerrainVolume(terrainVolume, new Region(xPos - range, yPos - range, zPos - range, xPos + range, yPos + range, zPos + range));
        //TerrainVolumeEditor.BlurTerrainVolume(terrainVolume, new Region(xPos - range, yPos - range, zPos - range, xPos + range, yPos + range, zPos + range));
        //TerrainVolumeEditor.BlurTerrainVolume(terrainVolume, new Region(xPos - range, yPos - range, zPos - range, xPos + range, yPos + range, zPos + range));
    }
}
