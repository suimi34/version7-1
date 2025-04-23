import Stores from '@/components/stores';

export default async function Home() {
  const res = await fetch(`${process.env.API_HOST}/api/stores`).then((res) => {
    if (res.ok) {
      return res.json()
    }
    throw new Error('Network response was not ok')
  })
  return (
    <Stores stores={res.stores} />
  )
}
